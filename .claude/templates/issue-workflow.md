# Template: Issue workflow (plan, delegate, review, PR)

## 1. PURPOSE
Take one GitHub issue from plan to open PR. Opus plans, a Sonnet subagent implements, ponytail-review checks the result. Philip approves twice: the plan, then the result.
For Philip, triggered by "work on issue #N", "do #N" or "issue workflow #N". One issue per run. For several issues, run it once per issue, one after the other.

## 2. INPUTS
- Repo (cwd) and the issue number.
- The planning step needs Opus 5.5 at xhigh effort. Claude can't switch its own model or effort. If the session runs on something else, or the effort is unknown, ask Philip to run `/model opus` and `/effort xhigh` before step 2.
- **Ask** when the issue is unclear or contradicts the code, before the plan.

## 3. STEPS
1. **Branch.** `git status` must be clean, or stop and ask. Then run `git switch main`, `git pull --ff-only` and `git switch -c <issue#>-<slug>`. Use the repo's branch naming if CLAUDE.md defines one.
2. **Plan (Opus, xhigh).**
   - Read the issue with its comments (`GH_PAGER=cat gh issue view N --json title,body,comments`, since plain `--comments` can print nothing), the repo's CLAUDE.md and every file the change touches.
   - Check which items of the issue are already done on main.
   - Write the plan to the scratchpad as `plan-<issue#>.md`. It covers the goal, the files with line numbers, numbered steps, tests to add, commands to run, what is out of scope and why, and the manual checks Philip has to do.
   - Show the plan. List the issue's weakest assumptions first, and mark open decisions D1, D2… each with a recommendation.
   - Wait for approval. Plan approval does not cover commits.
3. **Implement (subagent).** Start one Agent with `model: "sonnet"` and `effort: "high"`, without a worktree, so it works on the branch from step 1. The agent starts cold, so its prompt holds:
   - the full plan text
   - the test and build commands from CLAUDE.md
   - the rules: stay inside the plan, don't commit, don't push
   - what to report back: changed files, test results, and every step it skipped or changed, with the reason

   Don't touch the checkout while the agent runs.
4. **Review.** Run the `ponytail:ponytail-review` skill on the branch diff against main. Include the new untracked files. Then check the agent's report against the plan: every step must be done or explained.
5. **Present.** Show the result in the output format below. Don't fix anything yet.
6. **Ship (after approval).** This one approval covers commit, push and PR, and nothing else.
   1. Apply the review fixes Philip picked and rerun the tests.
   2. Commit in the style of `git log`, with the subject ending in `(#N)`. **No `Co-Authored-By` trailer.**
   3. Push with `git push -u origin <branch>`.
   4. Open the PR with `gh pr create`. The title is the commit subject. The body covers what changed and why, how it was tested, the manual checks still open, and `Closes #N`. No emoji.

   Docker images, tags and other branches need their own approval.

## 4. OUTPUT FORMAT
**Plan checkpoint (step 2):**
- Line 1: "Plan for #N ready: <goal in one line>. Branch `<branch>` is set up."
- `**Weak spots in the issue:**` ≤3 bullets.
- The plan: numbered steps, tests, out of scope.
- `**Decisions:**` D1… each with the recommendation first.
- Last line: "Approve the plan, or change D<n>?"

**Result checkpoint (step 5):**
- Line 1: "#N is implemented on `<branch>`: <what now works>. Tests: <n> passed, <n> failed. Nothing committed."
- `**Changed:**` ≤8 lines, one per file or group of files.
- `**Review:**` the ponytail-review findings, numbered, most severe first, or "No findings."
- `**Plan gaps:**` steps the agent skipped or changed, with its reason, or "None."
- `**Manual checks for you:**` what only Philip can test (browser, devices, image push).
- Last line: "Which findings should I fix (e.g. 'fix 1, 3')? Then I commit, push and open the PR."

**After step 6:** one line with the PR URL.

## 5. FINISHED EXAMPLE
None yet. After the first real run, save the result checkpoint reply as `issue-workflow.example.md` and link it here.

## 6. DONE CHECK
1. Did the branch start from an up-to-date main with a clean working tree?
2. Did Philip approve the plan before the subagent started, and the result before the commit?
3. Did the subagent get the full plan text, `sonnet` and `high`, and did it commit nothing?
4. Did ponytail-review cover the whole diff, new files included?
5. Is the commit free of `Co-Authored-By`, the PR body free of emoji and Generated with Claude Code, and does the PR say `Closes #N`?
6. Was nothing pushed beyond what Philip approved?
