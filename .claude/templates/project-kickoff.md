# Template: New project kickoff

## 1. PURPOSE
Start a new project. Understand it from its docs, legacy code or assignment, write CLAUDE.md, and for .NET projects scaffold Philip's standard solution.
For Philip, run on `/init` in a new folder. Homework that's meant for learning goes to skill `homework-coding` instead, so stop after step 3.

## 2. INPUTS
- Folder and what it is: real project, school project or demo
- Source material: `@docs`, a legacy repo, assignment text, tutorial URL
- Stack. The default for real projects is .NET 10 + Blazor (Interactive Server) + EF Core + Postgres. Kotlin is for Android, Angular for school web projects.
- **Ask** everything in the material that's unclear or contradictory before writing code: one message, at most 5 questions.

## 3. STEPS
1. Read all the source material. For a legacy codebase, list its bugs and bad patterns (missing auth, float money) so the rewrite avoids them.
2. Send the open questions. Don't guess the answers.
3. Write `CLAUDE.md` with these sections: Project, Current state, Architecture, Domain, Invariants/Rules, Commands (fish).
4. For .NET, scaffold:
   - `<Name>.slnx`
   - `src/<Name>.Data`: EF entities, one config file per entity, DbContext, migrations
   - `src/<Name>.Services`: class library with business logic, a `Add<Name>Services()` DI extension, `IDbContextFactory`
   - `src/<Name>.Web`: Blazor, where pages call services and never the DbContext
   - `tests/<Name>.Tests`: xUnit + Testcontainers Postgres
   - `docker-compose.yml` (Postgres) and `dotnet-tools.json` (dotnet-ef as a local tool)
5. Build with zero warnings, run the tests, then smoke-test the main flow (login or the first page) over HTTP.
6. Update CLAUDE.md to match what was actually built, then run `git init`. Ask before the first commit.

## 4. OUTPUT FORMAT
- Line 1: where it is, plus "builds with no warnings, tests pass, <flow> works".
- A code block with the tree, one line per project saying what it holds.
- `**What I tested:**` 2–4 concrete checks.
- `**Decisions you should know about:**` ≤5 bullets, each with its *why*.
- `**Local state:**` running containers, dev secrets/logins, git state.
- One line listing what isn't built yet.
- Last line: one question, usually "Should I make the initial commit?"

## 5. FINISHED EXAMPLE (Timeout rewrite, 2026-09-28, session e28b786f)
See `project-kickoff.example.md`.

## 6. DONE CHECK
1. Does it build with zero warnings, with the test project passing?
2. Are Data, Services and Web separate projects, with no page touching the DbContext directly?
3. Are the CLAUDE.md commands fish syntax, and do they match the real folder layout?
4. Was every open question asked before any code was written?
5. Is nothing committed or pushed without asking?
