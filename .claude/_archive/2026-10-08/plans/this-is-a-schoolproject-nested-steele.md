# Plan: Google Sheet backup for ClubFines

## Context
The club wants a human-readable copy of the data outside the app. Decisions so far:
- **Auth:** service account. One JSON key file on the server, and the Sheet is shared with the service account's email.
- **Write mode:** overwrite on every run. The user chose "just overwrite". Recovering from a bad export relies on Google Sheets' own version history.
- **Trigger:** nightly at 03:00 Europe/Vienna, plus an "Export now" button.
- **Backup admin page:** shows when the last export ran, whether it worked, and a link to the Sheet.

The Sheet is a mirror. pg_dump remains the restorable backup and is a separate, later task.

## Sheet layout (one tab per table, rewritten each run)
1. **Summary:** exported at (Vienna time), fund balance, open total, paid total.
2. **Fines:** date, player, fine type, season, amount, paid at, note. Notes stay in, because this is admin data and the Sheet is private.
3. **Players:** name, active, open amount.
4. **Fine types:** name, default amount, active.
5. **Seasons:** name, start date, current.

Each tab is cleared and then written with a single `BatchUpdate` call, so a failed run never leaves a tab half-cleared. Numbers are written as numbers (not "€ 5,00" strings), with a currency number format so the Sheet can do sums.

## Code

**Services (`src/ClubFines.Services/Backup/`)**
- `SheetExportBuilder`: reads the DB through `IDbContextFactory<ClubFinesDbContext>` (the same pattern as `FineService`) and returns `List<SheetTab>` (`record SheetTab(string Title, List<IList<object>> Rows)`). There is no Google dependency here, so it is testable with the existing Testcontainers fixture.
- `ISheetsClient`: `WriteAsync(string spreadsheetId, IReadOnlyList<SheetTab> tabs, ct)`. It creates missing tabs, then clears and writes.
- `GoogleSheetsClient : ISheetsClient`: uses `Google.Apis.Sheets.v4`, with `GoogleCredential.FromFile(path).CreateScoped(SheetsService.Scope.Spreadsheets)`.
- `SheetBackupService`: `RunAsync(ct)` = build, then write, then record the result. `GetStatusAsync()` returns the last run time, success or error message, and the Sheet URL.
  - It holds a `SemaphoreSlim` so the nightly run and a button click can't overlap.
- Register everything in `AddClubFinesServices()`. The Google client is only registered when `GoogleSheets:SpreadsheetId` is configured.

**Data**
- Add to `ClubSettings` (`src/ClubFines.Data/Entities/ClubSettings.cs`): `LastSheetExportAt` (UTC), `LastSheetExportSucceeded`, `LastSheetExportError` (max 500 characters).
- New migration: `AddSheetExportStatus`.

**Web**
- `Infrastructure/SheetBackupScheduler : BackgroundService`: computes the next 03:00 in `Europe/Vienna` via `TimeZoneInfo` and `TimeProvider`, so DST is handled. It waits, then calls `SheetBackupService.RunAsync`.
  - It catches and logs exceptions, so a failed run never crashes the app.
- `Components/Pages/Admin/Backup.razor` (`/backup`, Interactive Server, inherits `AdminPageBase`):
  - Status card: last export (date and time), ✓ or ✗ with the error text, and an "Open Sheet" link (`https://docs.google.com/spreadsheets/d/{id}`).
  - An "Export now" button that is disabled while an export runs.
  - When not configured, the page lists the setup steps instead.
- Add a "Backup" nav entry in `MainLayout.razor`. The phone nav becomes 3×2 → 3×3 grid rows (7 items).

**Config** (user-secrets locally, env vars in production, never in `appsettings`)
- `GoogleSheets:SpreadsheetId`
- `GoogleSheets:CredentialsPath`: path to the service-account JSON key.

## One-time Google setup (for you, about 10 minutes)
1. In Google Cloud Console, create a project, enable the **Google Sheets API**, then create a **service account** and download its JSON key.
2. Create an empty Google Sheet and share it with the service account's email as **Editor**.
3. Set the two config values: `dotnet user-secrets set "GoogleSheets:SpreadsheetId" "<id from the Sheet URL>" --project src/ClubFines.Web`, and the same for `CredentialsPath`.

## Tests
- `SheetExportBuilderTests` (Testcontainers): the tabs and headers are right, amounts are decimals, and the season names are resolved.
- `SheetBackupServiceTests` with a fake `ISheetsClient`:
  - A successful run records `Succeeded` and a timestamp.
  - When the client throws, the service records the error message and returns without throwing.
  - Two concurrent `RunAsync` calls only write once at a time.
- Scheduler: a unit test of the "next 03:00 Vienna" calculation, including a DST-change day.

## Verification
1. Run `dotnet build` and `dotnet test`: everything should pass.
2. With a real service account and Sheet configured, run the app, open `/backup`, click **Export now**, and check that all 5 tabs are filled and the Summary totals match the dashboard.
3. Break the key path and export again: `/backup` should show ✗ with the error, and the app keeps running.
4. Check that the "Open Sheet" link opens the right file.

## Effort
About 2–3 hours of implementation, plus about 10 minutes for your Google Cloud setup.
