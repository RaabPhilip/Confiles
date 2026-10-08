# CloudBoy: fixes to make before adding features

> **Approving this plan only creates the GitHub issues** (labels, milestone, tracking issue and 23 work issues, see the last section). **No code, config or repo files get changed.** The fixes are implemented later by you and the team, working from the issues.

## Context

It's a new school year, and before new features go in, CloudBoy's broken, unsafe or fragile parts should be fixed so features don't get built on top of them. The app will run on a **publicly reachable server**, so the security problems block everything else. GBA is **gated**: the backend rejects it and the UI hides it until multi-core support is built as a proper feature. The plan gets turned into **GitHub issues** that you, Jonas and Christian can pick from (see the last section).

**Pushback on "fix everything before features":** not all of this has to block. Phases 0–3 do, because every feature touches the emulator loop, auth or sessions. Phases 4–5 can run alongside feature work. The items under "Deferred" are architecture decisions, not fixes, and shouldn't hold up the year.

---

## Findings

"Verified" means I checked it in code or ran something. "Likely" means the reasoning is solid but it still needs a live check.

### P0: core loop broken / security (blocks everything)

1. **The emulator's event-loop handling is broken.** `streamer.py:40` calls `asyncio.get_event_loop()` at import time. On Python 3.14 this raises `RuntimeError` (verified locally on 3.14.7). The published image `raabpipo/raabpipo:v1.0.12` runs Python 3.14.0 (verified via registry metadata). Even on ≤3.13, `asyncio.run()` creates a *different* loop (verified), so `emulator.py:_set_video_refresh`'s `call_soon_threadsafe` sends frames to a loop that never runs. There are more problems in the same code:
   - `put_nowait` on a full `Queue(maxsize=1)` raises `QueueFull`.
   - `on_ice_candidate` calls `loop.create_task` from the GStreamer thread.
   - `send_sdp_offer` spins up a new event loop to send on an aiohttp socket that belongs to another loop.
2. **User endpoints are open.** `GET /api/users` (every user with their email) and `DELETE /api/users/{id}` require no auth (`WebApi/Endpoints/UserEndpoints.cs`). Anyone can delete any account.
3. **JWTs can be forged.** The signing key is committed in `appsettings.json` / `appsettings.Development.json`, and issuer/audience aren't validated (`Program.cs`). Anyone with repo access can mint tokens for the live server.
4. **Unlimited containers, which makes DoS trivial.** `POST /api/users/guest` is anonymous and `POST /api/signal` has no per-user or global cap. There's no idle timeout and no CPU/memory/pids limits on containers (`ContainerService.CreateContainer`).
5. **The signaling WebSocket has no auth.** The session ID is the only credential, and it's the same ID that goes into the public viewer link (`/watch/:sessionId`). A viewer can therefore connect as `frontend` (once the host's socket drops) or as `emulator`, and inject input or SDP (`SignalingEndpoints.cs`, `SessionService.AddClient`).
6. **No ownership check on session start.** `POST /api/signal` never checks that the ROM belongs to the caller, so you can play another user's ROM. `int.Parse` on the query string also turns bad input into a 500.
7. **Path traversal on upload.** `platform` goes unvalidated into `Path.Combine` (`RomService.UploadRomAsync`), so `?platform=../../x` writes outside `STORAGE_ROOT`. Files aren't checked for size or type either, so any file gets fed to a native C core.
8. **Emulator containers aren't hardened.** They run with `NetworkMode=host` as root with all capabilities, while the backend holds `docker.sock`. The ROM is untrusted input to native code.

### P1: correctness bugs that features would build on

9. **Sessions never clean up.** `SessionService.RemoveClient` checks `"Host"`/`"Peer"`, which never match the real roles, so only an explicit `close_session` kills a container. Closing the tab, a crash, or a dropped connection leaks the container forever. Sessions live only in memory with no container labels, so a backend restart orphans every running container.
10. **nginx defaults break the deployment.**
    - There's no `client_max_body_size`, so the 1 MB default applies and uploads over ~1 MB fail with 413 through :8080. Pokémon Red is exactly 1 MB.
    - The default `proxy_read_timeout` of 60 s is shorter than ASP.NET's 2-minute WebSocket keepalive. The host's signaling socket therefore dies after ~60 s idle, so late viewers can't connect and `close_session` is never sent. *(Likely; verify.)*
11. **The signaling relay handles framing and concurrency wrong.**
    - It does one 4096-byte `ReceiveAsync`. SDPs can be bigger, and `TryGetViewerTargetedMessage` and the `close_session` `Contains` check then run on fragments, so a large `host_answer` gets misrouted to the emulator.
    - Several relays call `SendAsync` on the same socket at the same time (emulator and viewers both sending to the frontend). WebSocket doesn't allow that and throws `InvalidOperationException`.
12. **The image tag is hardcoded.** `ContainerService` hardcodes `raabpipo/raabpipo:v1.0.12` and ignores `EMULATOR_IMAGE`, and it pulls the image on *every* session start. That slows startup and fails whenever Docker Hub is unreachable.
13. **Core and platform config is incoherent.**
    - `emulatorId` is ignored, so every session runs SameBoy. With the gating decision, the backend must reject anything that isn't `gb`/`gbc`, and the UI must hide GBA.
    - Production reads a host path (`/usr/lib/libretro/…`) from `appsettings.json`.
    - The compose `./cores` mount, `StorageInitializationService` and `backend/resources/*.so` are all unused.
14. **Refreshing `/play/:id` breaks the session.** `WebRtc` reads the session ID from `RomService`'s in-memory signal instead of the route. `EmulatorView` treats that route param (a session GUID) as the console ID, so the logo shows the GUID and the `data-console` styling never applies.
15. **Livestream host input has diverged from normal play.** `livestream-host.ts:249` sends `$event.key.toUpperCase()`. Arrow keys become `"ARROWUP"`, which the emulator ignores, and there's no remapping, gamepad or touch pad. Pressing `s` or `d` triggers the hidden save/load-state hotkeys in `emulator.py:handle_key_down`. Root cause: the WebRTC code is duplicated between `web-rtc.ts` and `livestream-host.ts`.
16. **Auth edge cases end in 500s or silent failures.**
    - `BCrypt.Verify` throws on the placeholder hashes (`"GUEST_USER"`, and the seeded user's), so logging in with those usernames returns a 500.
    - Registering with a duplicate email hits the unique index and returns a 500.
    - FluentValidation is registered, but no validators exist.
    - The seeded user has a real email address.
    - The frontend has no auth guard and no 401 handling, so an expired token just produces console errors.
    - `UserService` always stores `id: 0`.
17. **Guest users and their ROM files are never deleted.**

### P2: infrastructure and dev experience (can run in parallel with features)

18. **No working tests or CI.**
    - The frontend suite doesn't compile: `app.spec.ts` imports `App` (the class is `AppComponent`), `services/emulator.spec.ts` imports `Emulator` (the class is `EmulatorService`), and the `GameLib` spec has no HttpClient.
    - There's no backend test project.
    - There's no CI at all.
19. **Config is scattered across files that disagree.**
    - There are three DB names: `cloudboy` (compose), `postgres` (`appsettings.json`) and `db` (`ApplicationDbContextFactory`).
    - There are two compose files. `src/database/.env` uses `POSTGRES_USER: cloudboy` (a colon, so the variable is never set), and `init.sql` creates a junk `test` table.
    - TURN exists only in `src/database` compose, with a hardcoded `--external-ip=192.168.0.5`.
    - The frontend hardcodes `turn:localhost:3478` with credentials, and the livestream host/viewer only use STUN. A public deployment needs a real TURN setup.
20. **Production settings are too open:** CORS allows any origin, Swagger is on in prod, and `RequireHttpsMetadata=false`.
21. **The emulator image isn't pinned or hardened.** It builds from `python:latest` (unpinned), uses aiohttp 3.9.5 (old, with known CVEs), installs unused `pysdl2` packages, and runs as root.
22. **Logging floods the hot paths.** `emulator.py:_set_input_state` prints on every frame while a key is held (60 lines/s). The frontend logs on every keypress and ICE event.

### P3: repo hygiene

23. **Commercial ROMs are committed:** `tetris.gb` ×4, `prototype/pokemon.gb`, a `pokeyellow.gbc` inside `prototype/node_modules`, and a real user upload under `storage/1/gb/`. The repo is private, but this is exactly what the project promises not to do. Remove them from HEAD and add a free homebrew test ROM instead. **No history rewrite** (the repo is private, and you never rewrite commits).
24. **Committed build output and junk:** `prototype/` (71 MB, obsolete), `WebApi/app/build/*.dll`, `WebApi/dotenv.net.4.0.1/` (dotenv.net is referenced four times and used nowhere), `__pycache__/`, `.idea/`, `*.DotSettings.user`, and `.env` files.
25. **Dead or odd code:**
    - `Persistence/Services/ImportController.cs` is empty, and so is `LogDatabaseStatisticsAsync`.
    - `MapTestingEndpoint` is commented out.
    - `RomEndpoints` lives in `Endpoints/ä.cs`.
    - `ContainerService` is registered in DI but created with `new`, and its `DockerClient` is never disposed.
    - `EmulatorView` registers a `resize` listener and never removes it.

---

## Plan

Rough sizes assume one person working on it.

### Phase 0: baseline and safety net (~1–2 days, blocking)
- **Reproduce first.** Run `docker compose up --build`, start a GB session, and check `docker logs` on the emulator container to confirm #1 and #10 before changing anything.
- **Hygiene (#23, #24):**
  - Delete `prototype/`, the build artifacts, `__pycache__`, `.idea/`, the ROMs and `storage/`.
  - Keep a single homebrew test ROM (e.g. `src/emulator-service/resources/demo.gb`, **if its license checks out**).
  - Untrack the `.env` files, add `.env.example`, and fix the root `.gitignore` (it has duplicate entries and a broken `**/ .DS_Store` pattern).
- **Tests (#18):**
  - Fix the two broken spec imports and add `provideHttpClient()` / `provideHttpClientTesting()` to the specs.
  - Add `src/backend/Tests` (xUnit + `Microsoft.AspNetCore.Mvc.Testing` + `Testcontainers.PostgreSql`) with a `WebApplicationFactory<Program>` fixture.
- **CI:** add a GitHub Actions workflow that runs `dotnet build`/`dotnet test`, `ng test --watch=false --browsers=ChromeHeadless` plus `ng build`, and `docker build` for all three images.

### Phase 1: make the emulator actually stream (~1 day, blocking; #1, #12, #21, #22)
- `streamer.py`:
  - Build `Emulator` inside `main_application()` with `asyncio.get_running_loop()`.
  - Push frames through a helper that drops the stale frame when the queue is full.
  - Route every callback coming from the GStreamer thread (`on_offer_created`/`send_sdp_offer`, `on_ice_candidate`, data-channel messages) through `asyncio.run_coroutine_threadsafe(coro, self.loop)`.
  - Delete the new-event-loop hack.
- `emulator.py`: remove the `S`/`D` hotkeys (save states come back later as an explicit feature) and the per-frame prints.
- `Dockerfile`: pin the base image (e.g. `python:3.13-slim-bookworm`, whatever PyGObject 3.48 builds on), run as a non-root user, drop `pysdl2`, and bump aiohttp.
- `ContainerService`:
  - Read the image from `EMULATOR_IMAGE`.
  - Pull only if `InspectImageAsync` returns 404, which takes the pull off the session-start path.
  - Have CI tag images by git SHA.

### Phase 2: security (~3–4 days, blocking for public deploy; #2–#8, #16, #17, #20)
- **Users:**
  - Remove `GET /api/users` and `DELETE /{id}`, and add an authorized `DELETE /api/users/me`.
  - Add FluentValidation validators for the register and login records.
  - Check email uniqueness before insert.
  - Make guests' `PasswordHash` nullable and have login reject `IsGuest`/null-hash users before calling `BCrypt.Verify` (this needs a new migration).
  - Seed only in Development, with a real bcrypt hash and no real email.
- **JWT:**
  - Load the key from env (`JwtSettings__Key`) and fail at startup if it's missing or shorter than 32 bytes.
  - Validate issuer and audience against `JwtSettings:Issuer`/`Audience`, which are already in config, and set both when issuing tokens.
  - Pull token creation into one helper, since it's currently duplicated between login and guest.
- **Platforms (gating, #13):** add one `Platforms` map in `Core/Constants` (`gb`, `gbc` → SameBoy core path from config). Upload and session creation use it and return 400 for anything else.
- **ROM upload (#7):**
  - Validate `platform` against that map.
  - Enforce a max size of 8 MB.
  - Check the GB header: the Nintendo logo at `0x104` and the header checksum at `0x14D`.
- **Session start (#6):** bind `romFileId` as `int`, check ownership with `RomService.GetRomAsync` + `Utils.GetCurrentUserId` (`Persistence/utils/Utils.cs`), and return 400 if the ROM path is missing.
- **Signaling auth (#5):**
  - *frontend role:* JWT via `?access_token=`, read in `JwtBearerEvents.OnMessageReceived` for `/api/signal`, and `session.UserId` must match the caller.
  - *emulator role:* `CreateSession` generates a per-session random secret, passes it to the container as `EMULATOR_TOKEN` (`settings.py` appends it to `SERVER_URL`), and the backend compares it with `CryptographicOperations.FixedTimeEquals`.
  - *viewer role:* a separate random `ViewerToken` on `Session`. The share link becomes `/watch/:viewerToken`, and a viewer token can never claim another role.
- **Limits (#4, #8, #17):**
  - One active session per user: starting a new one closes the old one.
  - A global cap from config (`MaxSessions`).
  - `HostConfig` gets `Memory`, `NanoCPUs`, `PidsLimit`, `CapDrop=["ALL"]` and `SecurityOpt=["no-new-privileges"]`.
  - ASP.NET rate limiter on `/api/users/guest` and `POST /api/signal`.
  - A daily cleanup that deletes guests older than 24 h together with their ROM files.
- **Prod config (#20):** CORS origins from `AllowedOrigins` config, Swagger only in Development, no secrets in `appsettings.json`.

### Phase 3: session lifecycle and signaling robustness (~2–3 days, blocking; #9, #10, #11)
- **Disconnect handling:**
  - `RemoveClient` switches on `SocketRoles`.
  - If the emulator disconnects, close the session.
  - If the frontend disconnects, start a grace period (30 s, configurable) and close the session unless it reconnects.
- **Reaper:** a `SessionReaperService : BackgroundService` enforces idle and max-duration timeouts.
- **Orphans:** label containers `cloudboy.session=<id>`, and at startup (next to the DB/storage init in `Program.cs`) remove every labeled container, since sessions are in-memory only.
- **Relay rewrite:**
  - Wrap each socket in a small `SignalingConnection` (the socket plus a `SemaphoreSlim` send lock) stored on `Session`.
  - Read until `EndOfMessage` into a pooled buffer with a 64 KB cap.
  - Parse the JSON once and route on `event`.
  - Replace the string `Contains` checks.
- **nginx:** `client_max_body_size 16m`, and a separate `location /api/signal` with `proxy_read_timeout 1h`.
- **Keepalive:** `UseWebSockets(new WebSocketOptions { KeepAliveInterval = TimeSpan.FromSeconds(30) })`.

### Phase 4: frontend consolidation (~2 days, parallel to features; #14, #15, #16, #19)
- **Shared connection service:** extract `EmulatorConnectionService` (signaling WS, `RTCPeerConnection`, data channel, input forwarding from `InputManagerService.emulatorButtonEvent$`). `WebRtc` and `LivestreamHostComponent` both use it, and the host only adds the viewer fan-out on top.
- **Routing:**
  - Rename the route to `/play/:sessionId?platform=gb` and read both from the route.
  - `GameLib.selectRom` passes `platform`.
  - Drop the session state from `RomService`.
- **ICE config:** ICE servers come from `environment` (TURN URL and credentials), with no hardcoded localhost.
- **Auth:**
  - Add an `authGuard` on the protected routes.
  - Add 401 handling to `auth.interceptor.ts` (log out and redirect to `/auth`).
  - Load the real user via `getMe()`.
- **GBA gating:** hide GBA in the `emulator-selector` list.
- **Cleanup:** remove the `resize` listener leak and the hot-path `console.log`s.

### Phase 5: config and deployment consolidation (~1–2 days, parallel; #13, #19, #25)
- **Compose:**
  - One root compose file, with coturn added and its external IP taken from env.
  - Delete `src/database/` (compose, `.env`, `init.sql`), or turn it into `compose.override.yml`.
  - Use the DB name `cloudboy` everywhere, including the dev connection string and `ApplicationDbContextFactory`.
- **Core path:** set `Storage__EmulatorCore` explicitly in compose and document the host path in `.env.example`. Remove `StorageInitializationService`, `backend/resources/` and the unused `./cores` mount (or make it the documented source).
- **Dead code (#25):**
  - Rename `ä.cs` to `RomEndpoints.cs`.
  - Delete `ImportController.cs`, the empty `LogDatabaseStatisticsAsync` and the commented-out code.
  - Put `DockerClient` in a DI singleton and make `ContainerService` disposable.
- **Docs:** update the gotchas in `CLAUDE.md` so it doesn't describe bugs that have been fixed.

### Deferred (feature work, not fixes)
- **GBA / multi-core:** mGBA core, and video caps taken from `retro_get_system_av_info`.
- **Audio.**
- **Persistent SRAM saves and save states** (user story #4).
- **Bridge networking for emulator containers:** needs TURN to relay media, which is why host mode stays for now.
- **Session persistence / multi-host scaling:** Redis or DB-backed sessions, Kubernetes.

## Critical files
- `src/emulator-service/streamer.py`, `emulator.py`, `settings.py`, `Dockerfile`, `requirements.txt`
- `src/backend/WebApi/Program.cs`, `Endpoints/UserEndpoints.cs`, `Endpoints/SignalingEndpoints.cs`, `Endpoints/ä.cs`
- `src/backend/Persistence/Services/SessionService.cs`, `ContainerService.cs`, `RomService.cs`, `DatabaseInitializationService.cs`
- `src/backend/Core/Entities/Session.cs`, `User.cs`, plus a new `Core/Constants/Platforms.cs`
- `src/frontend/nginx.conf`, `src/app/web-rtc/web-rtc.ts`, `livestream-host/livestream-host.ts`, `app.routes.ts`, `core/interceptors/auth.interceptor.ts`, `services/rom.ts`, `services/user.ts`
- `docker-compose.yml`, `.env.example` (new), `.gitignore`, `.github/workflows/ci.yml` (new)

## Verification
- **Phase 0:** CI is green. `npm test -- --watch=false --browsers=ChromeHeadless` compiles and passes. `dotnet test src/backend` passes.
- **Phase 1:** after `docker compose up --build` and starting a GB session, video plays in the browser and all buttons respond. The container logs show no `RuntimeError`/`QueueFull` and no per-frame spam. A second session start doesn't pull the image again.
- **Phase 2:** integration tests assert:
  - `DELETE /api/users/1` without a token → 401.
  - Another user's ROM → 403.
  - `platform=../x` or `gba` → 400.
  - A token signed with the old committed key → 401.
  - A WS connection as `frontend` without a token → 401, and a viewer token used as `frontend` → rejected.
  - A second session for the same user closes the first.
  - `docker inspect` on an emulator container shows memory/pids limits and dropped capabilities.
- **Phase 3:**
  - Closing the tab removes the container within the grace period (`docker ps --filter label=cloudboy.session`).
  - Restarting the backend removes orphaned containers.
  - A viewer joining after 5 min idle gets the stream via :8080.
  - A 2 MB ROM uploads via :8080.
  - A unit test covers reassembly of a message larger than 4 KB and viewer routing.
- **Phase 4:**
  - Refreshing `/play/…` reconnects.
  - On the livestream host, arrows, gamepad and remapped keys all work, and `s`/`d` do nothing special.
  - GBA is hidden.
  - An expired token redirects to `/auth`.
- **Phase 5:** on a fresh clone, `cp .env.example .env && docker compose up --build` works end to end.

---

## GitHub issues to create (252627-BHIF-SYP/CloudBoy)

This follows the repo's existing conventions: English titles, bodies structured like #54 (Problem / Scope checklist / Done when), branches named `<issue#>-<slug>`. Issues are left **unassigned** so people can assign themselves.

**Repo setup (created first)**
- **New labels:** `security`, `area: backend`, `area: frontend`, `area: emulator`, `area: infra`. The existing labels `bug`, `enhancement`, `documentation` and `good first issue` get reused.
- **New milestone `Stabilization`** (no due date; rename it to fit your sprint scheme). It holds everything that must be done before new features, i.e. Phases 0–3 plus the tracking issue. The Phase 4–5 issues get no milestone.

**Tracking issue: "Stabilization before new features"** (milestone)
- Context, and the rule: everything in the milestone gets done before new features.
- Per-phase checklists that link every issue in order.
- Ownership notes, the Deferred list, and a final checkbox for updating CLAUDE.md.

**Work issues** (created in this order so "Blocked by #N" can link to real numbers)

| # | Title | Labels | Milestone | Depends on / coordinate |
|---|---|---|---|---|
| A | Clean up repository: remove ROMs, build artifacts and obsolete prototype | area: infra | ✓ | Do first. Heads-up that `.env` becomes `.env.example` |
| B | Fix frontend test suite so `ng test` runs | area: frontend, bug, good first issue | ✓ | |
| C | Add backend integration test project | area: backend | ✓ | Security issues add their tests here |
| D | CI: build and test on every PR | area: infra | ✓ | B, C; coordinate with #54 (it covers push/deploy, D covers tests only) |
| E | Emulator crashes on startup / frames sent to wrong event loop | area: emulator, bug | ✓ | Related #47 |
| F | Pin and harden the emulator Docker image | area: emulator | ✓ | E |
| G | Make emulator image configurable and stop pulling it on every session | area: backend | ✓ | Align with the GHCR plan in #54 |
| H | Lock down user endpoints and fix auth 500s | area: backend, security, bug | ✓ | C |
| I | Move JWT key out of the repo, validate issuer/audience, rotate the key | area: backend, security | ✓ | |
| J | Validate ROM uploads and session start (path traversal, platform whitelist, ownership) | area: backend, security, bug | ✓ | C |
| K | Authenticate signaling WebSocket roles (frontend / emulator / viewer) | area: backend, area: frontend, area: emulator, security | ✓ | E, I |
| L | Limit sessions, container resources and guest accounts | area: backend, security | ✓ | |
| M | Production config: CORS origins, Swagger, HTTPS metadata | area: backend, security, good first issue | ✓ | |
| N | Rewrite signaling relay: full message reads and serialized sends | area: backend, bug | ✓ | Related #47 |
| O | Sessions and emulator containers are never cleaned up | area: backend, bug | ✓ | N |
| P | nginx: upload size limit and WebSocket timeout | area: infra, bug, good first issue | ✓ | Related #47 |
| Q | Share one WebRTC connection service between play and livestream host | area: frontend, bug | — | K; related #47 |
| R | Read session from the route so reloading `/play` works | area: frontend, bug | — | Q |
| S | Frontend auth guard and 401 handling | area: frontend | — | |
| T | Hide GBA until multi-core support exists | area: frontend, good first issue | — | J |
| U | TURN/ICE configuration for the public deployment | area: infra, area: frontend | — | |
| V | Consolidate docker-compose and configuration | area: infra | — | A |
| W | Remove dead code and noisy logging | area: backend, area: frontend, area: emulator, good first issue | — | |

**Ownership note (goes in the tracking issue):** K, N and O all rewrite `SignalingEndpoints.cs` / `SessionService.cs`, and Q and R both rewrite `web-rtc.ts` / `livestream-host.ts`. Each group should have **one owner**, or the issues should be done strictly in order, to avoid painful merge conflicts.

**Execution**
1. `gh label create …` ×5, then create the milestone with `gh api repos/252627-BHIF-SYP/CloudBoy/milestones -f title=Stabilization`.
2. Write each body to the scratchpad. Create the tracking issue first, then A–W in order with `gh issue create --title … --body-file … --label … [--milestone Stabilization]`, recording each new number.
3. Edit the tracking issue body to fill in the checklist with the real issue numbers.
4. Bodies include "Part of #<tracking>", "Blocked by #N" and "Related #47/#54". GitHub adds the cross-reference to #47 and #54 by itself, so no comments get posted on existing issues.
5. **Verify:** `gh issue list --milestone Stabilization` shows the tracking issue plus A–P, and the tracking issue's checklist renders with 23 linked issues.
