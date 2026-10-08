# Plan: certificate download demo on the detail page

## Context
For a demo, the detail page needs a box where you pick a file format and download the certificate for that calibration. Decisions made with you:
- **Content:** real data. OpenXml builds a simple .docx from `CalibrationDetail`. PDF = that docx sent through Gotenberg. This is the same pipeline the real generator will use, but **not** the E+E template layout yet.
- **Formats:** Word (.docx), PDF, and DCC XML shown in the list but disabled ("folgt").
- **Placement:** a full-width "Zertifikat" card at the top of the detail page, above Kopfdaten.

## Key decision: download through JS interop, not an HTTP endpoint
A `MapGet` endpoint plus `<a download>` would need no JS. But if Gotenberg is down, the browser just shows a "failed download", and the page can't show its usual `MudAlert`. With interop, the file is built inside the circuit, the button shows a spinner for the ~2 s that Gotenberg takes, and errors land in the page's existing alert pattern. It needs a ~10-line browser helper (the `DotNetStreamReference` → Blob pattern from the MS docs).

**⚠ Plain JS, not TS:** you prefer TypeScript, but this one 10-line collocated module (`.razor.js`, same as the existing `ReconnectModal.razor.js`) would otherwise need `Microsoft.TypeScript.MSBuild` and a compile step. My recommendation is plain JS here. Say so if you want TS anyway.

## Changes

### SCP_Services
1. `SCP_Services.csproj`: keep the already-added `DocumentFormat.OpenXml` and add `Microsoft.Extensions.Http` (for `AddHttpClient`).
2. `Certificates/CertificateFormat.cs`: enum `Word, Pdf, DccXml`. `DccXml` only exists so the UI can list it. The service throws `NotSupportedException` for it.
3. `Certificates/CertificateFile.cs`: record `(string FileName, string ContentType, byte[] Content)`. The file name is `KA026466.docx` / `.pdf`, built with `CalibrationDetail.KaNumber`.
4. `Certificates/CertificateWordWriter.cs`: `byte[] Write(CalibrationDetail)` using OpenXml in a `MemoryStream`:
   - Title "Kalibrierschein / Calibration Certificate" plus a visible line "Demo: vereinfachtes Layout, kein gültiger Kalibrierschein".
   - A two-column key/value table for the header fields: manufacturer (joined with " / "), type, serial, customer lines, KA number, date of receipt, date of calibration, calibration mark. Empty values print "–".
   - One heading per run (source file + calibration date), then the humidity table with the certificate columns (Nr., calibration temperature, reference RH, output RH, deviation, uncertainty). Specification and confirmation are added only if any point has them.
   - Numbers and dates use de-AT, `dd.MM.yyyy`, same as the detail page. `ScpCulture` lives in the frontend, so the service uses `CultureInfo.GetCultureInfo("de-AT")` itself.
5. `Certificates/GotenbergPdfConverter.cs`: typed `HttpClient`, `Task<byte[]> ConvertAsync(byte[] docx, string fileName, CancellationToken)`. It sends a multipart POST to `forms/libreoffice/convert` with the field `files` (as in the CLAUDE.md spike) and calls `EnsureSuccessStatusCode`.
6. `Certificates/CertificateService.cs`: `Task<CertificateFile?> CreateAsync(long calibrationId, CertificateFormat format, CancellationToken ct)`. It reloads the data through `CalibrationDetailService.GetAsync` (by id, so the file never comes from stale page data), returns `null` if the calibration doesn't exist, writes the docx and converts it for PDF.
7. `ServiceCollectionExtensions.AddScpServices`: add a `Uri gotenbergUrl` parameter, register `CertificateService` as scoped, and add `AddHttpClient<GotenbergPdfConverter>(c => c.BaseAddress = gotenbergUrl)`.

### SCP_Frontend
8. `Program.cs`: read `Gotenberg:BaseUrl` and throw if it's missing, the same pattern as `Dashboard:GoLiveDate`.
9. `appsettings.Development.json`: `"Gotenberg": { "BaseUrl": "http://localhost:3000/" }`.
10. `Components/Shared/CertificateDownloadCard.razor` (+ `.razor.js`):
    - Parameter `CalibrationDetail Detail`.
    - `MudPaper Outlined` with the title "Zertifikat" (h6/h2, like the other cards) and a row with `MudSelect<CertificateFormat>` "Format" (default **PDF**; DCC XML is `Disabled` with "(folgt)") and a `MudButton` "Herunterladen" (Primary, Filled, `Download` icon).
    - While generating, the button is disabled and shows a `MudProgressCircular`.
    - If generation fails: log it, then show an inline `MudAlert Severity.Error` ("PDF konnte nicht erstellt werden. Läuft Gotenberg?" for PDF, generic text otherwise). The circuit stays alive.
    - If `Detail.Runs.Count == 0`, the button is disabled and shows the hint "Noch keine Messdaten". This follows "only show what needs action".
    - JS module `downloadFile(fileName, streamRef)`: arrayBuffer → Blob → object URL → click a temporary `<a download>` → revoke the URL. It's loaded lazily via `import("./Components/Shared/CertificateDownloadCard.razor.js")`, and the component disposes it in `DisposeAsync`.
11. `CalibrationDetailPage.razor`: add `<MudItem xs="12"><CertificateDownloadCard Detail="d"/></MudItem>` as the first item of the `MudGrid`.
12. `_Imports.razor`: `@using SCP_Services.Certificates`.
13. `SCP_Frontend/README.md`: add `Gotenberg:BaseUrl` to the required config keys, plus the `docker run` command.

## Not in scope
The E+E template rebuild, the certificate table / "Fertig" status, uploading an edited docx, and DCC XML. Everything is commented as demo, so nobody mistakes the simple layout for the real certificate.

## Verification
1. `dotnet build SmartCalibrationProvider.slnx`: no errors.
2. `docker start mssql-dev`, then `docker run -d --rm --name gotenberg -p 3000:3000 gotenberg/gotenberg:8`.
3. From `SCP_Frontend/`, run `dotnet watch`. Open the dashboard and click KA026466.
4. Download Word, open it in LibreOffice, and check the header fields and humidity table against the page.
5. Download PDF. Check that it opens and matches the docx.
6. Check that DCC XML is greyed out and can't be selected.
7. Run `docker stop gotenberg`, then download PDF again. Expected: an inline error alert, the page still works, and Word downloads still work.
8. Open a calibration with "Keine Messdaten". Expected: the button is disabled and the hint is shown.
