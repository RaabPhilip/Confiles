# Import the standard texts into the DB

## Context

The certificate generator needs E+E's standard text blocks (procedure, measurement uncertainty, remarks, conditions, result notes, conformity, specification, device descriptions). They're catalogued in `docs/Standardtexte.md` but not in the DB yet. This adds SCP tables for them, seeds every block from the catalogue, and maps machines to their procedure text.

Decided with the user:
- Texts are stored **verbatim**, typos included (generated output must match the real certificates; fixing is a later UPDATE script once E+E agrees).
- Catalogue section 1 (fixed layout: accreditation box, validity sentence, field labels, signature lines) **stays in the Word template**, not in the DB. Section 8 (E+E's annotations) isn't text either.

## Design

Three new tables, E+E conventions (`ObjID BIGINT IDENTITY`, `This2…` FKs, `CreatedAtUTC`/`CreatedBy2User`/`ModifiedAtUTC`/`ModifiedBy2User` with defaults, user columns `0`), like `002_create_certificate_inputs.sql`.

**`CertificateTexts`**: one row per block, DE + EN in the same row.
- `Code NVARCHAR(100) NOT NULL UNIQUE`: catalogue ID (`VERF_PRIMAERFEUCHTE`, `MU_GUM_AA`, …). This is also what the rebuilt template's content controls will reference, so there's no template table.
- `Section NVARCHAR(50) NOT NULL`: `Kalibriergegenstand`, `Beschreibung`, `Messergebnisse`, `Konformitaet`, `Spezifikation`, `Bedingungen`, `Verfahren`, `Messunsicherheit`, `Anmerkungen` (documented in the script, no CHECK so adding a section doesn't need a constraint change).
- `TextDE`, `TextEN NVARCHAR(MAX) NULL`, CHECK at least one not null (some blocks are DE-only, `ANM_AS_RECEIVED` is EN-only).
- `Accreditation NVARCHAR(3) NULL`: `AA`, `BEV`, `NULL` = both.
- `SortOrder INT`, `IsActive BIT DEFAULT 1`, `Notes NVARCHAR(MAX)`: source templates, cert count, ⚠ typo note.
- Conditions (`BED_*`) store the **label** as text (`Umgebungsdruck` / `Ambient pressure`); the value goes in the options table.

**`CertificateTextOptions`**: choice lists for placeholders that vary per certificate.
- `This2CertificateText` FK, `Placeholder NVARCHAR(50)` (`Schnittstelle`, `Geräteart`, `Messgrößen`, `Fühler`, `Element`, `Wert`, `Ablauf`, …), `ValueDE`, `ValueEN NVARCHAR(400)`, `SortOrder`, `IsDefault BIT`, `IsActive BIT`, audit columns. UNIQUE (`This2CertificateText`, `Placeholder`, `ValueDE`).
- Covers e.g. the interface list (`Analogausgang / analog output`, `RS485 -Schnittstelle / RS485 -interface`, …), supply voltage values, `(980 ± 20) hPa` as default for `BED_UMGEBUNGSDRUCK`, load resistor `22 kΩ` / `180 Ω`.

**`MachineProcedureTexts`**: `This2Machine` (UNIQUE, FK → `Machines.ObjId`) → `This2CertificateText` (FK). UNIQUE enforces one procedure per machine; several machines share one text row (UwRefA–D → MK_01_01). No column added to E+E's `Machines`.

### Seeding rules

- **Placeholders `{Name}` only for values that vary per certificate** (e.g. `{Schnittstelle}`, `{Typ}`, `{Kanal}`, `{Maßnahme}`). Values that are fixed per template become separate literal rows instead, e.g. `MU_MITTEL_REF_PRUEFLING` → `…_100_10_100S`, `…_100_10_10S`, `…_10_10_10S`; `KONF_ALT` → `KONF_ALT_OHNE_MU` / `KONF_ALT_MIT_MU`; `VERF_DRUCK_GENERATOR` → MK_13_01 (Ruska) and MK_13_02 (Mensor) rows; `KOPF_KALIBRIERGEGENSTAND` → one row per device kind.
- Blocks the catalogue flags as "only in faulty certificates, maybe the error itself" (`ERG_SENSOR_ERNEUERT`, `ANM_AS_RECEIVED`, the CP/CF legend is fine since templates have it) are seeded with `IsActive = 0`.
- Insert by `Code` only if missing, **never update existing rows** (E+E may have edited texts in production). Options and mappings: insert if the (text, placeholder, value) / machine row is missing.
- Machine mapping looks machines up **by `Name`**, not ObjID (prod IDs may differ). Only verified mappings: UwRefA/B/C/D → MK_01_01, Mess5 → MK_01_06, HUMOR-T → MK_01_02, HDG2 → MK_01_08, HDG3 → MK_01_07, Blockkalibrator → MK_11_01, GK1 → MK_03_01, DFA2 → MK_12_02. Left unmapped (guesses in the catalogue): Feuchtegenerator, GK2, WK40, WK2, DFA1, Druck1, Druck2, VorOrt HUMOR.

## Files

1. `Database/schema/004_create_certificate_texts.sql`: the three tables, `IF OBJECT_ID(...) IS NULL` guards.
2. `Database/schema/005_seed_certificate_texts.sql`: all blocks from catalogue sections 2–7 as `N'…'` literals in a table-variable `VALUES` list, then `INSERT … WHERE NOT EXISTS`. Same for options (keyed by `Code`) and machine mappings (keyed by machine `Name`). Saved as **UTF-8 with BOM** (±, Ω, ≙, ², ⁴, „“ must survive SSMS and sqlcmd); header comment says to run sqlcmd with `-f 65001`.
3. `Database/tables.sql`: add drops for the three tables (detail first) for the local reset.
4. `SCP_Data/README.md`: add `--table CertificateTexts --table CertificateTextOptions --table MachineProcedureTexts` to the scaffold command; re-scaffold → new `SCP_Data/Entities/CertificateText.cs` etc., `ScpDbContext.cs` regenerated.
5. `questions.md`: new section "Standardtexte": typo list (catalogue §10.1/10.2) and the unmapped machines (§10.5).
6. `CLAUDE.md` + `Database/schema/README.md` if needed: replace "Standard texts … aren't in the DB yet" with the table names and the seeding rules (verbatim, never update, placeholders only for per-certificate values).

No service or UI changes; reading the texts belongs to the generator work.

## Verification

1. Run both scripts against the dev DB **twice** (`docker exec mssql-dev /opt/mssql-tools18/bin/sqlcmd -C -f 65001 -S localhost -U sa -P … -d SCP_DB -i …`, after `docker cp`); second run must insert 0 rows and not error.
2. Spot-check via pymssql: `SELECT COUNT(*)` per section; `TextEN` of `VERF_PRIMAERFEUCHTE` contains "Jule 3rd"; `BED_UMGEBUNGSDRUCK` default option = `(980 ± 20) hPa` with the `±` intact; `MU_GUM_AA` EN contains `distribution.The`.
3. Machine mapping: join `Machines` → `MachineProcedureTexts` → `CertificateTexts`, expect 11 mapped machines, 8 unmapped.
4. Re-scaffold, then `dotnet build SmartCalibrationProvider.slnx` passes.
5. Show `git diff --stat`; commit on `feature/cert-generation` only after the user OKs (no push).
