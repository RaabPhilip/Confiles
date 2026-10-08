# Archive 2026-10-08 — AI setup audit

Nothing here is loaded by Claude Code. To restore, move the item back to its original path.

## Files
| Archived as | Original path |
|---|---|
| skills/homework-other/ | ~/Confiles/.claude/skills/homework-other/ |
| skills/real-project/ | ~/Confiles/.claude/skills/real-project/ (scope line merged into CLAUDE.md) |
| projects/AvaloniaDemo-CLAUDE.md | ~/Github/Pose/AvaloniaDemo/CLAUDE.md |
| claude-desktop-skills/*.skill | ~/Claude/Skills/ |
| memory/home/timeout-rename.md | ~/.claude/projects/-home-pipo/memory/ (+ its line in MEMORY.md) |
| memory/my-homelab/* | ~/.claude/projects/-home-pipo-Github-my-homelab/memory/ |
| memory/AvaloniaDemo/* | ~/.claude/projects/-home-pipo-Github-Pose-AvaloniaDemo/memory/ (said homework-coding; you chose direct code) |
| plans/*.md | ~/.claude/plans/ |
| gemini/dot-gemini/ | ~/.gemini (not in git: holds OAuth credentials) |
| plugin-cache/ | ~/.claude/plugins/cache/… (not in git: re-downloadable) |
| CLAUDE.md | ~/Confiles/.claude/CLAUDE.md (pre-interview version, replaced by the 15-rule file) |
| config/ | snapshots of settings.json, installed_plugins.json, known_marketplaces.json, CAL .claude/settings.json, MCP servers |

## Plugins removed (fish)
```fish
claude plugin install superpowers@claude-plugins-official
claude plugin install skill-creator@claude-plugins-official
claude plugin marketplace add pbakaus/impeccable; and claude plugin install impeccable@impeccable
claude plugin marketplace add dotnet/skills   # then install dotnet-blazor / dotnet-data in the CAL repo
claude plugin install csharp-lsp@claude-plugins-official   # also needs csharp-ls installed
claude plugin marketplace add ayghri/i-have-adhd   # only if you want the plugin instead of the local skill
claude plugin enable coach@synced   # coach was disabled, not uninstalled (managed on claude.ai)
```

## MCP removed
```fish
claude mcp add --transport http -s user rider http://127.0.0.1:64482/stream
```

## Gemini CLI
Config archived. Program still installed: `sudo npm uninstall -g @google/gemini-cli`
Restore config: `mv ~/Confiles/.claude/_archive/2026-10-08/gemini/dot-gemini ~/.gemini`
