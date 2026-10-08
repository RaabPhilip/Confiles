# Dashboard list (Home.razor)

## Context

`Home.razor` is an empty page, and `SCP_Services` has no services yet. The dashboard should list the calibrations that need action (requirement: "only show certificates that actually need action", few clicks), each with the workflow status chip from `SCP_Frontend/README.md`.

The README left one question open: "Keine Messdaten" would match every historical calibration. **Decided (by you):** status + date rule. A calibration is listed if

- SCP already has `CalibrationRuns` for it, **or**
- its E+E status is `neu` (ObjID 1) or `In Bearbeitung` (ObjID 17), **and** `CreatedAtUTC >= Dashboard:GoLiveDate` (config).

Dev DB with `GoLiveDate = 2026-01-01` gives 110 open orders plus KA026466 (the only imported run, which E+E already has as `Versendet`).

What we can derive today: no runs → `NoMeasurements`, runs → `InProgress`. `Finished` needs a certificate table, which doesn't exist yet. So the enum and chip include it, but the service never returns it for now.

## Changes

### SCP_Services: new folder `Calibrations/` (namespace `SCP_Services.Calibrations`)

- `CertificateStatus.cs`: `enum CertificateStatus { NoMeasurements, InProgress, Finished }`.
- `DashboardOptions.cs`: `public sealed record DashboardOptions(DateTime GoLiveDate);`
- `CalibrationOverviewItem.cs`: a DTO record with `CalibrationId` (ObjID), `CalibrationNumber` (int?), `Status`, `Customer`, `DeviceType`, `SerialNumber`, `ReceivedOn` (DateTime?), `CalibratedOn` (DateOnly?), `Worker`. Computed `KaNumber => CalibrationNumber is { } n ? $"KA{n:D6}" : "–"` (26473 → `KA026473`).
- `CalibrationOverviewService.cs`: primary ctor `(IDbContextFactory<ScpDbContext> dbFactory, DashboardOptions options)`. Method `GetDashboardAsync(CancellationToken ct = default)` does one EF query with a short-lived context (the pattern from `SCP_Data/README.md`):
  - `Where(c => c.CalibrationRuns.Any() || ((c.This2Status == StatusNew || c.This2Status == StatusInProgress) && c.CreatedAtUtc >= options.GoLiveDate))`
  - Sort order: rows with runs first, then `CalibrationNumber` descending.
  - Projection into the record. Customer = `CertName ?? This2CustomerCompanyNavigation.Name` (1,902 recent rows have no `CertName`). Type = `CalibrationSpecimen`. Calibration date = `CalibrationRuns.Max(r => r.CalibrationDate)`. Worker = `This2WorkerNavigation.Name`. Status = `CalibrationRuns.Any() ? InProgress : NoMeasurements`.
  - `private const long StatusNew = 1, StatusInProgress = 17;` with a comment: these are E+E `Status.ObjID` values, and the dev DB is a copy of production (**assumption, confirm with E+E**).
- `ServiceCollectionExtensions.AddScpServices(string connectionString, DateTime goLiveDate)`: `AddSingleton(new DashboardOptions(goLiveDate))` and `AddScoped<CalibrationOverviewService>()`. A plain parameter instead of `IOptions<>`: it follows the existing connection-string pattern and needs no config-binder package in the class library.

### SCP_Frontend

- `Program.cs`: pass `builder.Configuration.GetValue<DateTime?>("Dashboard:GoLiveDate") ?? throw new InvalidOperationException("'Dashboard:GoLiveDate' missing, see SCP_Frontend/README.md.")`. Like the connection string, it has no silent default.
- `appsettings.Development.json`: `"Dashboard": { "GoLiveDate": "2026-01-01" }`. Nothing goes in `appsettings.json`, so production has to set the real go-live date explicitly.
- `Components/_Imports.razor`: add `@using SCP_Services.Calibrations` and `@using SCP_Frontend.Components.Shared`.
- **New `Components/Shared/CertificateStatusChip.razor`**: `[Parameter] CertificateStatus Status`. A `switch` maps each status to label, icon, `Color` and `Variant`, exactly as in the README table (`HourglassEmpty`/`Default`/Outlined, `PendingActions`/`Tertiary`/Filled, `TaskAlt`/`Success`/Outlined). Renders `<MudChip T="string" Size="Size.Small" …/>` and always shows icon + text. It lives in its own component because the detail page will reuse it.
- **`Components/Pages/Home.razor`**: `@inject CalibrationOverviewService`, `ILogger<Home>`.
  - `MudDataGrid<CalibrationOverviewItem>` with `Items`, `Loading`, `QuickFilter`, `Hover`, `Dense`, `SortMode.Single`, `RowsPerPage="50"`. No `Filterable`: the quick search covers it without the English filter-menu UI.
  - `ToolBarContent`: title "Kalibrierungen", `MudSpacer`, search `MudTextField` (`Immediate`, `DebounceInterval="300"`, search icon, `Clearable`, placeholder "KA-Nr., Kunde, Typ, Seriennr."), refresh `MudIconButton`. The Excel macro imports while the page is open, and a manual reload is simpler than polling.
  - Columns: Kalibriernr. (`KaNumber`), Status (`TemplateColumn` with the chip, `SortBy = x => x.Status`), Kunde, Typ, Seriennr., Eingang (`Format="dd.MM.yyyy"`), Kalibriert (`dd.MM.yyyy`), Bearbeiter.
  - `NoRecordsContent`: "Keine offenen Kalibrierungen." `PagerContent`: `MudDataGridPager` with German `RowsPerPageString` / `InfoFormat`.
  - Loading in `OnInitializedAsync` / refresh: `try/catch`, log the error, and show `MudAlert Severity.Error` instead of the grid. Without that, a DB outage would take down the whole circuit through the Blazor error UI.
  - The UI is in German, matching the README status labels.
- `SCP_Frontend/README.md`: replace the "**Open:**" bullet with the decided rule and the config key `Dashboard:GoLiveDate`.
- `CLAUDE.md`: `Home.razor` is no longer empty. Add one line on the dashboard rule and the config key.

### Risks to keep in mind

- **Label clash:** E+E's own status 17 is also called "In Bearbeitung" and means "calibration number assigned". Those rows (without SCP data) show up as "Keine Messdaten". Staff who know E+E's app might find that confusing. Not changing it for now, but ask the lab for feedback.
- The rule depends on E+E actually moving old orders out of `neu`. If a lot of stale `neu` rows pile up after go-live, add an age limit.

### Deliberately left out

- **Manufacturer column:** `CalibrationProducers` has two rows per calibration (`ProducerType` 0/1, different in 275 cases). It's unclear which one goes on the certificate, so that's a question for E+E, needed for the certificate at the latest.
- **Row click / detail page:** no target page exists yet, and a dead link doesn't help anyone. Add `RowClick` together with the detail page.
- **`Finished` / a "show finished" toggle:** comes with the certificate table.
- Server-side paging (`ServerData`): with the filter, the list stays at a few hundred rows, so loading it in memory is fine.

## Verification

1. `dotnet build SmartCalibrationProvider.slnx`: no errors.
2. `docker start mssql-dev`, then `dotnet watch` from `SCP_Frontend/` and open http://localhost:5135.
   - KA026466 is at the top with an indigo, filled "In Bearbeitung" chip. The rest have a grey, outlined "Keine Messdaten" chip.
   - Row count matches `SELECT COUNT(*) FROM Calibrations c WHERE EXISTS (SELECT 1 FROM CalibrationRuns r WHERE r.This2Calibration = c.ObjID) OR (c.This2Status IN (1,17) AND c.CreatedAtUTC >= '2026-01-01')` (expected 111).
   - Search "26466" leaves one row. Sorting by Status/KA-Nr. works. Dates show as `dd.MM.yyyy`.
3. Remove `Dashboard:GoLiveDate` from the config: startup throws with the message.
4. `docker stop mssql-dev` then refresh: a MudAlert appears, the circuit stays alive. Then `docker start mssql-dev` again.
5. No commit or push without asking.
