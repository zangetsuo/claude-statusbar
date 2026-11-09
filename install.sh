#!/bin/bash
# Installs the usage status line for Claude Code.
# Copies statusline-command.sh into the Claude config dir and sets the
# statusLine entry in settings.json, leaving every other setting untouched.
set -euo pipefail

force=0
[ "${1:-}" = "--force" ] && force=1

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
  dir="$CLAUDE_CONFIG_DIR"
  cmd="bash \"$dir/statusline-command.sh\""
else
  dir="$HOME/.claude"
  cmd='bash "$HOME/.claude/statusline-command.sh"'
fi
settings="$dir/settings.json"

command -v jq >/dev/null 2>&1 || {
  echo "jq is required. Install it first (macOS: brew install jq, Debian/Ubuntu: sudo apt install jq)." >&2
  exit 1
}

mkdir -p "$dir"
[ -f "$settings" ] || echo '{}' > "$settings"

jq -e . "$settings" >/dev/null 2>&1 || {
  echo "$settings is not valid JSON. Fix it and run the installer again." >&2
  exit 1
}

if [ "$force" -eq 0 ] && jq -e 'has("statusLine")' "$settings" >/dev/null; then
  echo "You already have a status line configured:"
  jq '.statusLine' "$settings"
  if [ -t 0 ]; then
    read -r -p "Replace it? [y/N] " answer
    case "$answer" in y|Y|yes|YES) ;; *) echo "Nothing changed."; exit 0 ;; esac
  else
    echo "Run again with --force to replace it." >&2
    exit 1
  fi
fi

backup="$settings.bak-$(date +%Y%m%d-%H%M%S)"
cp "$settings" "$backup"
cp "$here/statusline-command.sh" "$dir/statusline-command.sh"

tmp="$(mktemp)"
jq --arg cmd "$cmd" '.statusLine = {type: "command", command: $cmd}' "$settings" > "$tmp"
mv "$tmp" "$settings"

echo "Installed. Backup of your previous settings: $backup"
echo "The status line shows up after the next reply in Claude Code."
