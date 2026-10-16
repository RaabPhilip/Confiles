#!/bin/bash
# Claude Code status line:
#  ~/dir (branch* ↑1↓2) +120 -34 | Model · effort · ctx 42% | 5h 63% ↻14:20
input=$(cat)
get() { jq -r "($1) // empty" <<<"$input"; }

blue=$'\e[34m' green=$'\e[32m' yellow=$'\e[33m' red=$'\e[31m' magenta=$'\e[35m' dim=$'\e[2m' reset=$'\e[0m'
pct_color() { if (($1 >= 80)); then echo "$red"; elif (($1 >= 50)); then echo "$yellow"; else echo "$green"; fi; }

dir=$(get .workspace.current_dir)
model=$(get .model.display_name)
effort=$(get .effort.level)
ctx=$(get .context_window.used_percentage)
five=$(get .rate_limits.five_hour.used_percentage)
five_reset=$(get .rate_limits.five_hour.resets_at)
added=$(get .cost.total_lines_added)
removed=$(get .cost.total_lines_removed)
branch=$(git -C "$dir" branch --show-current 2>/dev/null)

line=" ${blue}${dir/#"$HOME"/\~}${reset}"
if [ -n "$branch" ]; then
  color=$green
  # --no-optional-locks: don't grab index.lock while a git command runs in the terminal
  if [ -n "$(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null)" ]; then
    dirty='*' color=$yellow
  fi
  # compares against the last fetch, no network call
  if counts=$(git -C "$dir" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
    read -r behind ahead <<<"$counts"
    ((ahead)) && sync+="↑$ahead"
    ((behind)) && sync+="↓$behind"
  fi
  line+=" ${color}(${branch}${dirty}${sync:+ $sync})${reset}"
fi
((added + removed)) && line+=" ${green}+${added}${reset} ${red}-${removed}${reset}"

line+=" ${dim}|${reset} ${magenta}$model${reset}"
[ -n "$effort" ] && line+=" ${dim}· $effort${reset}"
[ -n "$ctx" ] && line+=" ${dim}·${reset} $(pct_color "${ctx%.*}")ctx ${ctx%.*}%${reset}"
if [ -n "$five" ]; then
  line+=" ${dim}|${reset} $(pct_color "${five%.*}")5h ${five%.*}%${reset}${five_reset:+ ${dim}↻$(date -d "@$five_reset" +%H:%M)${reset}}"
fi
printf '%s' "$line"
