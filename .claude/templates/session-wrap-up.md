# Template: Session wrap-up (sync CLAUDE.md + commit)

## 1. PURPOSE
End of a work session in any repo: bring CLAUDE.md up to date if the state changed, write a good commit message, then commit.
For Philip, triggered by "commit it", "commit and update CLAUDE.md", or "update CLAUDE.md to the current status".

## 2. INPUTS
- Repo (cwd) and what the session changed. That comes from the conversation and the diff.
- Optional: "one commit" or split, "show me the message first", "only CLAUDE.md". Defaults: split by logical change, and commit without waiting.
- **Ask** only if the diff contains something that looks unrelated to the session.

## 3. STEPS
1. Run `git status` and `git diff --stat`. Anything that shouldn't be committed (`*.zip`, `files/`, `.env`, secrets, build output) goes into `.gitignore`, and you say so.
2. Read `git log -10` to match the repo's subject style. If he asked to see the message first, show it and wait.
3. CLAUDE.md: when structure, commands, config keys, the DB schema or the current state changed, edit only the affected sections ("Current state" almost always). If nothing changed, write "CLAUDE.md still accurate".
4. One commit per logical change. When the pieces build on each other, make one commit and explain why.
5. Write the message. Subject: imperative, ≤72 chars. Body: what changed and *why* for every decision the diff doesn't explain, as bullets when there are more than 2 changes, wrapped at 72. **No `Co-Authored-By` trailer.**
6. Commit as a new commit. Never amend, never push. Ask about the push at the end.

## 4. OUTPUT FORMAT
- Line 1: ``Committed `<hash>` on `<branch>`, <n> files, working tree clean. Nothing pushed.``
- The commit message in a code block. Skip it if he already saw it.
- `CLAUDE.md now covers:` ≤5 bullets naming the changed sections, **or** "CLAUDE.md still accurate".
- Follow-ups for other people or machines, e.g. "every dev's DB needs `schema/002_…sql` run once".
- Last line: ``Next: push `<branch>`?``

## 5. FINISHED EXAMPLE (CAL, 2026-10-07, commit 726c0af, session 8fd6bb65)
See `session-wrap-up.example.md`.

## 6. DONE CHECK
1. Is the message free of any `Co-Authored-By` line?
2. Is the working tree clean, or every leftover file listed with a reason?
3. Does CLAUDE.md's "Current state" match what was just committed?
4. Was nothing pushed and nothing amended?
5. Does the body give the *why* for each non-obvious decision?
