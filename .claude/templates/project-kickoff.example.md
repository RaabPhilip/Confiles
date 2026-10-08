# Example: Project kickoff (Timeout / ClubFines, 2026-09-28)

Real output from session e28b786f, prompt: "Set up the base structure of the Project, use separate projects for the EF, and a Class Library for Services if needed, and the Main Blazor app". Final reply pasted unedited (progress narration before it left out).

---

The base structure is in `~/Github/ClubFines`. It builds with no warnings, the test passes against a real Postgres, and the login works end to end over HTTP.

```
ClubFines.slnx
src/ClubFines.Data       entities, one config file per entity, DbContext (EF + Identity tables), initial migration
src/ClubFines.Services   business logic: FineService, Roles, AddClubFinesServices()
src/ClubFines.Web        Blazor app (Interactive Server): login/logout, admin folder, DB initializer
tests/ClubFines.Tests    xUnit + Testcontainers Postgres fixture, first test
docker-compose.yml       Postgres 17 for local dev
dotnet-tools.json        dotnet-ef as a local tool (run `dotnet tool restore` after cloning)
```

**What I tested:** with no login, `/` redirects to `/login`. A wrong password shows an error. The seeded admin can log in and sees the dashboard. A `returnUrl=//evil.example` sends you to `/` instead of the outside site.

**Decisions you should know about:**
- **Services use a DbContext factory**, not a normal scoped DbContext. In Blazor Server a "scoped" service lives as long as the browser session, so one context would be shared across everything a user does. The factory gives each operation its own short-lived context.
- **Admin protection is per folder.** `Pages/Admin/_Imports.razor` requires the Admin role for every page in that folder, so a new admin page can't be left unprotected by accident.
- **I didn't use the template's built-in login.** It generates about 30 pages (register, 2FA and so on) you don't need. Instead there's one login page and a `POST /logout` endpoint. The first admin is created at startup from user-secrets.
- **The database migrates itself on startup.** That's fine for a small club app with one instance.
- **The Services project is worth keeping.** It lets the tests run the real business logic against the database without starting Blazor.

**Local state:** I created a dev admin in user-secrets (`admin@clubfines.local` / `Dev-Passw0rd!`, change it if you like), and the Postgres container is still running (`docker compose down` stops it). `git init` is done, but nothing is committed yet.

CLAUDE.md now matches the real layout. Note that migrations now need `--project src/ClubFines.Data --startup-project src/ClubFines.Web`. Not built yet: the public token page, the Google Sheets export, the app Dockerfile and the pg_dump backup container.

Should I make the initial commit?

