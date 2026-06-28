# Cheat Sheet

## Herdr

Prefix is `C-a` (Ctrl+A).

### Session & project management

| Key | Action |
|---|---|
| `C-f` | Project picker — creates/focuses a Herdr workspace |
| `C-a s` | Full navigator — spaces, tabs, and panes |
| `C-a w` | Workspace picker |
| `C-a d` | Detach |
| `C-a r` | Reload Herdr config |
| `C-a D` | Close current/selected space |
| `C-a $` | Rename workspace |

### Temporary panes

| Key | Action |
|---|---|
| `C-a g` | Lazygit temporary pane |
| `C-a y` | Yazi temporary pane |
| `C-a i` | Open Obsidian Inbox.md in helix |
| `C-a o` | Fuzzy search all Obsidian notes, open selected in helix |
| `C-a 0` | Open btop temporary pane |

### Panes & tabs

| Key | Action |
|---|---|
| `C-a h/j/k/l` | Move between panes |
| `C-h/j/k/l` | Resize pane (no prefix) |
| `C-a z` | Zoom/unzoom pane |
| `C-a c` | New tab |
| `C-a ,` | Rename tab |
| `C-a 1-9` | Jump to tab |
| `C-a b` | Hide/show sidebar |

### Copy mode

| Key | Action |
|---|---|
| `C-a [` | Enter copy mode (vi keys) |
| `v` | Begin selection |
| `y` | Copy selection to clipboard |
| `q` | Exit copy mode |

---

## Helix

| Key | Action |
|---|---|
| `Space z` | Send selection to ipython REPL (auto-creates right pane on first use) |
| `Space q` | Quit |
| `Space x` | Save and quit |
| `R` | Reload file |
| `C-r` | serpl — project-wide search & replace |

---

## Zsh

| Command | Action |
|---|---|
| `z <dir>` | Jump to directory with zoxide (learns from `cd` history) |
| `ai <prompt>` | Run opencode with a prompt |
| `ssh host` | SSH + auto-attach to remote tmux (single-host form only) |
| `sn` | Fuzzy Obsidian note search (same as `C-a o`) |

---

## User guide

### Starting work on a project

1. Press `C-f` → pick your project folder.
2. A Herdr workspace opens with shell, agent, ipython, and ssh tabs.
3. If the project has a `.venv`, it's activated automatically in the project tabs.

### Running code from helix

1. Open a file in helix.
2. Select some code (visual mode), then press `Space z`.
3. An ipython pane opens on the right and runs the selection.
4. Subsequent `Space z` sends to the same pane.

### File navigation with yazi

1. Press `C-a y` to open yazi in a temporary pane.
2. Navigate to a file and press `Enter` to select.
3. Text files open in helix in the previously active Herdr pane. Other files open with the system viewer.

### Obsidian from the terminal

- `C-a i` — quick-open Inbox.md (for capturing thoughts).
- `C-a o` — fuzzy search all notes by path; paths shown relative to vault root.
- Requires `export vault="/path/to/vault"` in `~/.zsh_secrets`.

Notes:

- Herdr has temporary panes, not tmux popups, so popup workflows are close but not identical.
- New Kitty terminals launch Herdr through `herdr-init-default`.
- `herdr-init-default` ensures `default` and `btop` spaces exist, starts `btop`, focuses `default`, then attaches Herdr.
