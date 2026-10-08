# Spezifikation and Bewertung on calibration points

## Context

Some certificates carry an ILAC G8:09/2019 conformity statement, made on customer request
(3 of the 19 files in `Testzertifikate/`). When they do, the humidity table gains two
columns — **Spezifikation** (`±2.0`) and **Bewertung** (`P`/`F`) — plus a legend and a
"Spezifikation entsprechend Herstellerdatenblatt Typ X" line. `KA026388.pdf` and
`KA026507.pdf` have it, `KA026466.pdf` does not.

The workbook marks those cells the same way it marks everything else that goes on the
certificate: a green `92D050` fill. Verified across the sample workbooks:

| Sheet | Interface | Green columns | Certificate |
|---|---|---|---|
| `KA026466_2_01` | Analogmessung | I–N | no conformity columns |
| `#0008_2_01` (KA026388) | Analogmessung | I–**P** | prints Spezifikation + Bewertung |
| `KA026507T_01` | Handablesung | I–**O** | prints Spezifikation + Bewertung |

**The `Konformitätsbewertung` setting cannot be used instead.** `KA026466_2_01` and
`KA026507T_01` both hold `Ja - mit MU` in `G1`/`H1`, yet only KA026507's certificate has
the conformity block. The green marking is the only reliable signal.

Outcome: when those cells are green the importer stores them, and the detail page shows
them exactly when they exist.

## Decisions

- **Columns O (Spezifikation) and P (Bewertung)** — the analog layout. The `N`/`O` from
  the request is the Handablesung layout, which sits one column to the left because it
  has no "Anzeigewert mA" column. The importer cannot read those sheets at all yet, so
  that stays a separate change.
- **Read the point columns through a map**, keyed by layout, with only the analog entry
  filled in. Adding Handablesung later becomes one entry instead of a rewrite of the loop.
- **Spezifikation as raw text.** The certificate prints `±2.0` verbatim, and the value
  varies per row (`±1.3` … `±2.77` in KA026388, because the spec is % of reading).
  Parsing it would invent a semantic for a consumer that does not exist yet; a parsed
  column can be added later while 001 is still unhanded-over.
- **Bewertung with a `CHECK`** on the four values seen in real data. Consistent with
  `InterfaceKind`, `SignalType` and `Quantity`, and a shifted column writing junk into a
  conformity statement is worse than an import that stops.

## 1. Schema — `Database/schema/001_create_calibration_runs.sql`

Still not handed to E+E, so it is edited in place again. `CalibrationPoints` gains:

```sql
Specification NVARCHAR(20) NULL,   -- Spezifikation, e.g. '±2.0', stored as printed
Confirmation  NVARCHAR(4)  NULL,   -- Bewertung: P, F, CP, CF

CONSTRAINT CK_CalibrationPoints_Confirmation
    CHECK (Confirmation IS NULL OR Confirmation IN ('P', 'F', 'CP', 'CF'))
```

Both nullable and independent of each other: only green cells are stored, and most runs
have neither. A comment records that the green fill, not the `Konformitätsbewertung`
setting, decides whether these are filled.

## 2. Importer — `Database/extract_measurements.py`

- Replace the seven hardcoded `ws.cell(row=…, column=N)` reads in `extract_data()` with a
  module-level column map for the analog layout (`H` position … `O` specification,
  `P` confirmation), in the same style as the existing `CHANNEL_COLUMNS` / `CHANNEL_ROWS`
  constants. The row still qualifies on column I being green, as today.
- For O and P: take the value only when **that cell** is green, checked per cell with the
  existing `is_cell_green()`. Store as text, stripped; empty or non-green stays `None`.
- Extend the `INSERT` into `CalibrationPoints` with the two columns.

## 3. EF, services and UI

- Re-scaffold with the command in `SCP_Data/README.md`. No new table, so the `--table`
  list is unchanged.
- `SCP_Services/Calibrations/CalibrationDetail.cs`: `HumidityPoint` gains
  `string? Specification` and `string? Confirmation`.
- `CalibrationDetailService.cs`: add both to the point projection (the anonymous shape
  and the `Select((p, index) => …)` mapping).
- `SCP_Frontend/Components/Shared/HumidityPointsTable.razor`: render the two extra
  columns **only when at least one point in the run has a value**, mirroring the
  certificate, which omits them entirely otherwise. Headers "Spezifikation" and
  "Bewertung", values as stored (no formatting — they are text, not numbers).

## Verification

1. Re-import `KA026466.xlsm` / `KA026466_2_01` → six points, `Specification` and
   `Confirmation` both `NULL`; detail page shows the table unchanged at six columns.
2. Import `KA026388.xlsm` / `#0008_2_01` → seven points with `Specification` `'±1.3'`,
   `'±1.34'`, … and `Confirmation` `'F'`. Cross-check the values against
   `Testzertifikate/KA026388.pdf`, which prints both columns.
   **Note:** that sheet name does not match `KA0(\d+)`, so the run imports with
   `This2Calibration = NULL` and never reaches the detail page. For the UI check use
   `KA026388_nj.xlsm` (sheet `KA026388_2_01`) after confirming it has the same green
   columns — otherwise verify the UI by temporarily pointing at the KA026388 run.
3. `dotnet build SmartCalibrationProvider.slnx` — expect zero warnings.
4. Detail page for the KA026388 run: eight columns with `±1.3` / `F`; the KA026466 run
   still shows six.

## Open for E+E

`KA026507T_01` holds `CP` in the Bewertung column, but `KA026507.pdf` prints `P` for that
row and its legend defines only `P Pass` and `F Fail`. What `CP`/`CF` mean and how they
are meant to print is unknown — the raw value is stored, the rendering rule needs asking.

## Not included

- **The Handablesung/Digital column layout** (the gotcha already in CLAUDE.md). It needs
  `CalibrationPoints.OutputCurrentMA` to become nullable and a column map per
  `InterfaceKind`. The map introduced here is the hook for it.
- The `Konformitätsbewertung` setting and the "Spezifikation entsprechend
  Herstellerdatenblatt" text — both belong to certificate generation, not the import.
