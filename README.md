# claude-code-usage-statusline

A status line for [Claude Code](https://claude.com/claude-code) that shows your usage as bars, like `/usage`:

```
5h ████░░░░░░ 42% · Weekly ██░░░░░░░░ 18% · Context ███░░░░░░░ 31%
```

- **5h**: how much of the current 5-hour session limit you have used.
- **Weekly**: how much of the weekly limit you have used.
- **Context**: how much of the current conversation's context window is filled.

## Install

Requires `bash` and `jq` (macOS, Linux, or Windows through WSL / Git Bash).

```
git clone https://github.com/zangetsuo/claude-code-usage-statusline.git
cd claude-code-usage-statusline
./install.sh
```

The installer copies `statusline-command.sh` to `~/.claude/` and sets the `statusLine` entry in `~/.claude/settings.json`. It backs up `settings.json` first, changes nothing else in it, and asks before replacing a status line you already have (`./install.sh --force` skips the question).

## Notes

- The 5h and Weekly bars only appear on Claude subscription plans, and only after the first reply of a session. Until then you see `Context` alone, or `usage: waiting for data`.
- The bar color is the blue Claude Code uses in its dark theme. To change it, edit the `38;2;177;185;249` color code in `statusline-command.sh`.

## Uninstall

Remove the `statusLine` entry from `~/.claude/settings.json` (or restore the backup the installer created) and delete `~/.claude/statusline-command.sh`.
