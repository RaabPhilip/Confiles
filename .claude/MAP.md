# Map

Shared preferences: ~/.claude/CLAUDE.md. Read it first. This file only points.

## Request → where to go
| Request                                  | Go to                                              |
|------------------------------------------|----------------------------------------------------|
| Work in an existing project              | that project's CLAUDE.md (table below)             |
| Coding homework, learning by hints       | skill `homework-coding`                            |
| Non-coding homework                      | ~/Documents/Synology/school/26-27/<subject>        |
| Servers, Docker, DNS, VPN, VM networking | skill `homelab`, repo ~/Github/my-homelab          |
| Notes, todos, recipes, workouts          | ~/Documents/Synology/obsidian (+ `obsidian:*`)     |
| UI look and feel                         | skill `frontend-design`                            |
| Avalonia                                 | skill `avalonia`                                   |
| MudBlazor                                | skill `mudblazor` (CAL repo only)                  |
| Cleaning up CLAUDE.md files              | `claude-md-management:claude-md-improver`          |

## Projects
| Project              | Path                                   | Mode                      |
|----------------------|----------------------------------------|---------------------------|
| Timeout (club hub)   | ~/Github/ClubFines                     | default                   |
| CAL SmartCalibration | ~/Github/CAL_SmartCalibrationProvider  | default                   |
| CloudBoy             | ~/Github/CloudBoy                      | default                   |
| FineManager (legacy) | ~/Github/FineManager                   | default                   |
| AvaloniaDemo (Pose)  | ~/Github/Pose/AvaloniaDemo             | default — write code directly, not homework |
| my-homelab           | ~/Github/my-homelab                    | homelab                   |

## Templates (repeat jobs: read the template before doing the job)
- Project status / "what's next": ~/Confiles/.claude/templates/project-status.md
- Linux/Arch error or broken thing on archibald: ~/Confiles/.claude/templates/linux-troubleshoot.md
- New project / `/init` / .NET scaffold: ~/Confiles/.claude/templates/project-kickoff.md
- "commit it" / "update CLAUDE.md": ~/Confiles/.claude/templates/session-wrap-up.md
- How-to note into the Obsidian vault: ~/Documents/Synology/obsidian/.claude/templates/how-to-note.md

## Other places
- Memory: ~/.claude/projects/<path-with-dashes>/memory/ (managed by Claude Code)
- Skills: ~/.claude/skills → ~/Confiles/.claude/skills. Keep flat. synced/ is Anthropic's, don't edit
- Archive: ~/Confiles/.claude/_archive/<date>/. Never loaded; README says how to restore
