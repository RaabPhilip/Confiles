# Template: Linux troubleshooting (archibald)

## 1. PURPOSE
Find the cause of a problem on Philip's laptop and give the fix in fish. Covers errors, broken hardware, failing installs, VPN and VM issues.
For Philip. He wants to understand *why* it broke, but in one paragraph, not an essay. Server and homelab problems go to skill `homelab` instead.

## 2. INPUTS
- Error text or screenshot
- What he was doing: the command, app, or tutorial URL
- **Ask** only if the trigger can't be inferred: "Which command or action shows this?"

## 3. STEPS
1. Identify the component: package, service, driver, config file.
2. Check the real state read-only before you guess. Useful commands: `pacman -Qs`, `pacman -Qo <file>`, `systemctl status`, `journalctl -b -u <unit>`, `ls -l /etc/...`, `ip -brief addr`, `virsh uri`, `hyprctl monitors`.
3. Pin down **one** cause and say what proved it. If a config file has no owning package or changed recently, say so, along with when.
4. Write the fix. Sudo commands are for Philip to run, because Claude has no TTY for the password. Use `paru` for AUR packages.
5. Give a check command and its expected output.
6. If he'll need this again, offer an Obsidian note (`obsidian/.claude/templates/how-to-note.md`).

## 4. OUTPUT FORMAT
- Line 1: `**Cause:** <one sentence>`. If it's still unknown, line 1 is the single diagnostic command to run instead.
- One short paragraph: why that causes the symptom.
- `**Fix**` (fish): a code block, plus one line per non-obvious command explaining what it does.
- A warning before anything destructive: removing packages, editing `/etc`, reboot.
- `**Check:**` the command plus what success looks like.
- Last line: what to paste back if it still fails.
- At most 30 lines. Don't list five possible causes.

## 5. FINISHED EXAMPLE (display stuck at 1024x768, 2026-09-29, session 432cf3ec)
See `linux-troubleshoot.example.md`.

## 6. DONE CHECK
1. Is there one cause, backed by something actually checked on the system and not a "could be"?
2. Are all commands fish syntax, with pacman/paru, and every sudo command marked for Philip to run?
3. Do Hyprland snippets target the Lua config (`~/.config/hypr/hyprland.lua`), with no `hyprland.conf` / `exec-once =` syntax?
4. Is there a check command with its expected result?
5. Is every destructive step flagged *before* its command?
