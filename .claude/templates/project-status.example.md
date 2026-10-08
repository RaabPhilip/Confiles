# Example: Project status (CAL SmartCalibrationProvider, 2026-10-05)

Real output from session a8911f46, prompt: "Get an overview of the current status of the project only regarding my part, and create me a list of what to do next". Pasted unedited.

---

**Start here:** send E+E the open-questions mail (list below, ~20 min). Their answers take days to arrive, and several later steps wait on them.

## Where your part stands

**Done**
- Excel importer: humidity points, interface kind, analog channels, conformity columns. Handles the Analog and Handablesung layouts.
- Dashboard (PR 400) and the read-only detail page (PR 401). Both are merged into `main`.

**Empty**
- You're on `feature/cert-generation` and it has zero commits beyond `main`. No certificate generation code exists yet, and that's the core of your thesis part.

**Missing**
- Certificate generation, a certificate table, the as-found/as-left flag, temperature points, standard texts, editing/approval, roles, tests.
- The detail page still shows 13 fields with a `Pending` hint (`CalibrationDetailPage.razor:49–168`). That's a good checklist of which data has no source yet.

**Things I found in the repo**
- `files/HTL Leonding Diplomarbeit/` (gitignored) holds **19 real Word templates** (`Zertifikatsvorlagen/*.docx`), the reference PDFs in `Testzertifikate/`, and 10 test workbooks. CLAUDE.md doesn't mention any of this, but it's exactly what the generator needs.
- There's still no digital sample with data. `KA026587` is marked `Logging`, but its sheet doesn't use the standard layout (row 14 is empty).
- In Handablesung, the temperature table is also shifted: yellow cells are S–X, not S–Y, because there's no mA column. The temperature import needs a column map per interface kind, just like the humidity table has.
- The DA-Antrag milestones all ended on 13.09.2026. If your supervisor treats them as binding, tell them about the new timeline.

## What to do next

**Phase 1: unblock (this week, ~2 h total)**
1. Mail E+E these questions (~20 min):
   - What's the rule for ambient pressure, i.e. how do they get from bar to "(980 ± 20) hPa"?
   - What do ProducerType 0 and 1 mean?
   - Where does the supply voltage come from?
   - Can they send a digital workbook with data?
   - Which `.docx` is the humidity template?
   - Can they send the standard texts (procedure per measuring station, uncertainty, remarks)?
   - What login do they use (Windows/AD?), for the role concept?
2. Agree with Fabian on the JSON certificate model (~1 h). His validation runs on it, so it's the only interface between your two parts. Base it on DCC.

**Phase 2: data model (`Database/schema/002_…`, ~2–3 days)**
1. Add the as-found/as-left flag to `CalibrationRuns`. Change the unique key from `SourceFile` to `(SourceFile, Sheet)`. Give the importer a 3rd argument (half a day).
2. Import temperature points (yellow), with a column map per interface kind (½–1 day).
3. Add a `Certificates` table with status, staff inputs (device description, "adjusted" flag, remarks) and approved by/at. This also lets you derive the "Fertig" status (half a day).
4. Add a `TextBlocks` table for the standard texts. Seed it from the templates (half a day).

**Phase 3: certificate generation (~1 week)**
1. Spike (1 day). My recommendation: fill E+E's existing `.docx` templates with OpenXML and convert them to PDF with headless LibreOffice. That way E+E keeps maintaining the layout in Word, and you deliver the "Word/PDF" the DA-Antrag promises. QuestPDF would be faster to build, but every layout change would then need a developer. Check before you commit to it: does LibreOffice run on E+E's Windows server?
2. Build `CalibrationDetail` → certificate model → JSON (1 day).
3. Run the humidity template end-to-end for KA026466 and compare the output against `Testzertifikate/KA026466.pdf` (2–3 days).

**Phase 4: workflow UI**
1. Edit mode on the detail page for the staff inputs.
2. "Zertifikat erstellen" button plus preview and download.
3. Approval step and roles.
4. The Excel macro that calls the importer.

**Ongoing**
- Use the PDFs in `Testzertifikate/` as golden-file tests for the generator. Test the importer against the 10 workbooks.
- Start writing the thesis chapters on data sources and the data model now (deadline 01.04.2027).

The "Current state" section in CLAUDE.md is out of date: it still says the detail view is in progress, and it doesn't mention `files/`. Want me to update it?

**Next:** write the E+E mail. Want me to draft it in German from the questions in Phase 1?
