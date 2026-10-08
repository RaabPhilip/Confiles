# Certificate generation: gap analysis and plan

## Context

SCP can import humidity points and show every certificate field on the detail page (`/calibrations/{id}`), but it can't produce a certificate yet. Next milestone (DA-Antrag: "Automatische Zertifikatserstellung", planned 07.08.2026, now overdue) is turning a calibration into the bilingual RH certificate PDF (`docs/Zertifikat-kommentiert.pdf`). This file lists what's missing and the order to close the gaps in.

## What already exists and gets reused

- `SCP_Services/Calibrations/CalibrationDetailService.GetAsync()` → `CalibrationDetail`: KA number, type, serial, producers (join with " / "), customer address lines, receipt date, calibration date, calibration mark, Bearbeiter, worksheets/machines, runs with interface kind, analog channels, humidity points numbered 1..n.
- `CalibrationDetail.CalibrationMark`, `CertificateAddress.Lines`, `CalibrationNumbers.ToKaNumber()`.
- `ConfigurationText()` in `CalibrationDetailPage.razor` (analog "Konfiguration" line). Move it into the service layer so page and certificate share it.
- `CertificateStatus.Finished` exists but can't be derived yet.

## What's missing

### A. Blocks any PDF at all
1. **Rendering approach + library.** No Word template in the repo, only the annotated PDF. No PDF/DOCX library referenced.
2. **Intermediate certificate model** (`CertificateDocument`): the JSON-serializable snapshot the requirements ask for (validation input for Fabian, DCC-inspired). Nothing like it exists; `CalibrationDetail` is a DB read model.
3. **Layout assets:** Akkreditierung Austria/E+E logos, font, exact margins. Need them from E+E (or the .dotx they use today).

### B. Blocks a complete, correct certificate
1. **As-found/as-left flag** on `CalibrationRuns` (schema 002 + importer arg + `SourceFile` uniqueness per sheet). Without it the renderer can't split runs into Eingangs-/Ausgangskalibrierung.
2. **Temperature points** (yellow rows, S–Y): not imported, no table. The sample certificate has a temperature table in both sections.
3. **Standard texts** (procedure per machine, measurement uncertainty, remarks, interface statements "Kalibrierung über digitale Schnittstelle"/analog/Handablesung, sequence note): no table, and E+E has to supply the texts per machine.
4. **Staff inputs, persisted:** device description (short on p.1, long on p.2), "vor der Kalibrierung justiert", extra remarks, supply voltage. Needs an SCP `Certificates` table (one row per calibration + revision).
5. **Calibration conditions:** ambient pressure rule unknown. "(980 ± 20) hPa" and "(23 ± 3) °C" look like fixed lab ranges, not measurements. `RoomControlMeasurements` isn't scaffolded and has no usable index (27M rows).
6. **Number formatting:** the certificate uses a decimal *point* (22.9, 14.95) even in German; `ScpCulture.Austrian` would print commas. Decimals differ per column (temp 1, RH 2), stored values are `decimal(5,2)`. Rounding rule for uncertainty (GUM) to confirm.
7. **Conformity layout** (Spezifikation/Bewertung columns + ILAC G8 text) when present: need a sample (KA026507).
8. **Digital interface** isn't importable, but the sample certificate is a digital one.

### C. Blocks production use
1. **Certificates table + status:** "Fertig", locking on approval, revision path (ISO/IEC 17025 7.8.8).
2. **Authentication:** the app has none, so approval can't record who approved (Zeichnungsberechtigter).
3. **Digital signature:** "Dieses Dokument ist digital signiert." Needs E+E's signing certificate/process.
4. **Where the final PDF goes:** DB blob vs. file share (`Calibrations.FolderName` hints at a folder per calibration).

## Recommended order

| Phase | Result | Estimate |
|---|---|---|
| 1 | Preview PDF from the data that exists, watermarked "ENTWURF", placeholders for missing parts | 1–2 days |
| 2 | As-found/as-left flag + temperature import (schema 002, importer, detail page) | 1–2 days |
| 3 | Text blocks table + `Certificates` table with editable staff fields | 2–3 days + waiting on E+E texts |
| 4 | Approval, locking, "Fertig" status, final PDF storage | 2–3 days, auth depends on E+E |
| 5 | Digital signature | unknown until E+E says how they sign today |

Why preview first: it surfaces every missing field visibly, gives Fabian the `CertificateDocument` to validate against, and doesn't depend on E+E answers.

## Phase 1 detail (pending decisions below)

_To be filled after the rendering decision._

## Verification

_To be filled with phase 1 detail._
