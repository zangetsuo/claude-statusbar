#!/bin/bash
# Claude Code status line: usage (5h / weekly / context), compact one line.
input=$(cat)

command -v jq >/dev/null 2>&1 || { echo "usage: jq not found"; exit 0; }

bar() { # percentage -> 10-cell bar, e.g. ████░░░░░░
  local pct filled i
  pct=$(printf '%.0f' "$1")
  [ "$pct" -lt 0 ] && pct=0; [ "$pct" -gt 100 ] && pct=100
  filled=$(((pct + 5) / 10))
  [ "$pct" -gt 0 ] && [ "$filled" -eq 0 ] && filled=1
  # Octal escapes (UTF-8 bytes) so the bar survives any locale.
  # Filled cells in Claude Code blue (rgb 177,185,249), empty cells in gray (240).
  printf '\033[38;2;177;185;249m'
  for ((i = 0; i < filled; i++)); do printf '\342\226\210'; done
  printf '\033[38;5;240m'
  for ((i = filled; i < 10; i++)); do printf '\342\226\221'; done
  printf '\033[0m'
  printf ' %d%%' "$pct"
}

five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')

out=""
add() { if [ -n "$out" ]; then out="$out · $1"; else out="$1"; fi; }

[ -n "$five" ] && add "5h $(bar "$five")"
[ -n "$week" ] && add "Weekly $(bar "$week")"
[ -n "$ctx" ] && add "Context $(bar "$ctx")"
if [ -z "$five" ] && [ -z "$week" ] && [ -n "$cost" ]; then
  add "$(printf 'cost: $%.2f' "$cost")"
fi

[ -z "$out" ] && out="usage: waiting for data"
printf '%s\n' "$out"
