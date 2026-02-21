# Cheat Sheet

## Tmux

Prefix is `C-a` (Ctrl+A).

### Session & project management

| Key | Action |
|---|---|
| `C-f` | Sessionizer — fuzzy pick from `~/Projects`, creates or attaches session |
| `C-a s` | Session switcher — built-in tmux list; killing current session switches to next available |
| `C-a d` | Detach from session |
| `C-a $` | Rename session |

### Popups

| Key | Action |
|---|---|
| `C-a g` | Lazygit (opens in current pane's directory) |
| `C-a y` | Yazi file picker — selecting a file sends `hx <file>` to window 1 |
| `C-a i` | Open Obsidian Inbox.md in helix |
| `C-a o` | Fuzzy search all Obsidian notes, open selected in helix |

### Panes & windows

| Key | Action |
|---|---|
| `C-a h/j/k/l` | Move between panes |
| `C-k/j/h/l` | Resize pane (no prefix) |
| `C-a z` | Zoom/unzoom pane |
| `C-a c` | New window |
| `C-a ,` | Rename window |
| `C-a 1–9` | Jump to window by number (window 9 is always btop) |

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
2. A new tmux session opens with 3 windows. Window 9 is shared btop across all sessions.
3. If the project has a `.venv`, it's activated automatically in all 3 windows.

### Running code from helix

1. Open a file in helix.
2. Select some code (visual mode), then press `Space z`.
3. An ipython pane opens on the right and runs the selection.
4. Subsequent `Space z` sends to the same pane.

### File navigation with yazi

1. Press `C-a y` to open yazi in a popup.
2. Navigate to a file and press `Enter` to select.
3. Text files open in helix on window 1. Other files open with the system viewer.

### Obsidian from the terminal

- `C-a i` — quick-open Inbox.md (for capturing thoughts).
- `C-a o` — fuzzy search all notes by path; paths shown relative to vault root.
- Requires `export vault="/path/to/vault"` in `~/.zsh_secrets`.
