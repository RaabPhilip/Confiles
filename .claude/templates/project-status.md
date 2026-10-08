# Template: Project status + next steps

## 1. PURPOSE
A snapshot of where a project stands and a phased to-do list. Use it when Philip picks a project back up or asks "what's the current state, what's next".
For Philip. In team projects (CAL, CloudBoy) it covers only his part unless he says otherwise.

## 2. INPUTS
- Project path (default: cwd)
- Scope: whole project, or "my part only". **Ask** if it's a team project and he didn't say which.
- Optional: deadline or milestone doc. If none is given, look for one in `docs/`.

## 3. STEPS
1. Read `CLAUDE.md`, `README.md` and any plan or milestone file in `docs/`. Also check the Obsidian to-do notes for the project, because feature plans often live only there: `grep -rli '<project or old name>' ~/Documents/Synology/obsidian --include=*.md`.
2. Run `git status`, `git branch -vv` and `git log --oneline -20`. Note commits ahead of `main` and anything unpushed.
3. Grep for stubs: `TODO`, `Pending`, `NotImplemented`, placeholder UI text. Also list gitignored material folders like `files/`.
4. Sort the findings into Done (proven by a commit, merged PR or code you read), In progress or empty, and Missing.
5. Find blockers that wait on other people (answers from E+E, an interface with a teammate). Those go first.
6. Compare what you found with CLAUDE.md's "Current state" or "Planned / not built yet" section, and with any open checkboxes in Obsidian. Note where they differ in both directions: work that's done but not ticked off, and work that's planned but not written down.
7. Write the output below.

## 4. OUTPUT FORMAT
- Line 1: `**Start here:** <one action> (~<time>)`
- `## Where your part stands`, made of bold sub-blocks **Done** / **Empty** or **In progress** / **Missing** / **Things I found in the repo**. Each block has ≤5 bullets, with `file:line` where useful.
- `## What to do next`, made of `**Phase N: <goal> (<when>, ~<total time>)**` headers. Under each, numbered steps (≤5), each with its own time estimate. Phase 1 is always "unblock" when anything waits on other people.
- One line saying whether CLAUDE.md is stale, offering to update it.
- Last line: `**Next:** <one action or yes/no question>`
- English, direct, 40–70 lines. Texts meant for German stakeholders get drafted in German, but only when he asks.

## 5. FINISHED EXAMPLE (CAL, 2026-10-05, session a8911f46)
See `project-status.example.md` next to this file. It's pasted there in full.

## 6. DONE CHECK
1. Is the first line one concrete action with a time estimate?
2. Is every "Done" item backed by a commit, merged PR or file actually read, and not only by CLAUDE.md?
3. Does every step have a time estimate, with ≤5 steps per phase?
4. Is everything that waits on other people in Phase 1?
5. Does it say whether CLAUDE.md and the Obsidian to-dos still match reality?
