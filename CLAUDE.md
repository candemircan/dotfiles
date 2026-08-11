# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, zoxide, starship, aliases, local AI functions) + `.local/bin/` scripts
- `herdr/` — `.config/herdr/config.toml` (primary terminal workspace manager, prefix `C-a`)
- `tmux/` — `.tmux.conf` (legacy rollback config, prefix `C-a`, TPM, flexoki dark theme)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font, boots into Herdr)
- `helix/` — `.config/helix/` (gruvbox dark, REPL pipe, serpl, LSP config)
- `ruff/` — `.config/ruff/pyproject.toml` (global Ruff lint defaults)
- `claude/` —  agent skills (`baklavacutter`, `docments-to-docstrings`) + `.claude/managed-settings.json` (machine-level safety policies) + `.claude/output-styles/KISS.md` (global output style; enabled via `outputStyle` in `~/.claude/settings.json`)
- `pi/` — `.pi/agent/` (Pi defaults and OpenCode Go model provider)
- `sandbox/` — `Containerfile` for the `node22-uv` agent sandbox image (node:22 + uv). Not a stow package; built by `install.sh`, so don't add it to the stow loop
- `git/` — `.gitconfig` (shared Git settings and identity); machine-local overrides go in `~/.gitconfig.local` (not tracked)

### `zsh/.local/bin/` scripts

| Script | Purpose |
|---|---|
| `tmux-init-default` | Legacy tmux rollback helper; creates the `default` session (window 1 shell, window 9 btop) |
| `sessionizer` | fzf over `~/Projects` + `~/Projects/cpi`; creates/attaches sessions, activates `.venv` |
| `tmux-yazi` | Yazi chooser popup; text files → `hx`, others → system opener |
| `tmux-obsidian` | Opens `$vault/Inbox.md` in helix (reads `~/.zsh_secrets`) |
| `herdr-sessionizer` | fzf project picker; creates/focuses Herdr workspaces and tabs |
| `herdr-space-switcher` | fzf over Herdr spaces only; focuses selected space |
| `herdr-yazi` | Yazi chooser temporary pane; text files open in the previously active Herdr pane |
| `herdr-init-default` | Starts/attaches Herdr, ensures `default` and `btop` spaces |

### `.zshrc` functions

| Function | Purpose |
|---|---|
| `ai <prompt>` | Run opencode with a prompt |
| `sclaude`, `spi` | Sandboxed agents — rootless OCI container (`node22-uv` = node:22 + uv, built from `sandbox/Containerfile`; falls back to plain `node:22` if unbuilt): podman on Linux (`:Z` mounts for SELinux), `apple/container` on macOS. Only `$PWD`, `.container_venv` → `.venv`, a shared uv cache (`~/.cache/uv-container`), and agent state are mounted. Claude OAuth persists via `~/.claude`; Pi gets `OPENCODE_GO_KEY`/`OPENCODE_API_KEY` and persists state in `~/.pi_cache` |
| `sn` | Fuzzy Obsidian note search |
| `count <dir>` | Count files in a directory |

## Scripts

- `install.sh` — Full bootstrap: installs brew, tools, agents, plugins, then runs `stow.sh`.
- `stow.sh` — Symlinks all packages, wires agent skills, and shares instructions across agents.



## Agent skills

Skills come from two stores, neither tracked in this repo.

`~/.agent-skills/` — hand-maintained skill directories. The `stow.sh` skill loop links **every** one into both `~/.claude/skills/` and `~/.pi/agent/skills/`. This store cannot target a single agent.

`~/.agents/skills/` — skills installed by the `skills` CLI (`npx skills add`), invoked from `install.sh`. Use this store when a skill belongs to only some agents. `--agent` takes space-separated agent ids (`claude-code`, `pi`); commas are rejected.

| Skill | Source | Agents |
|---|---|---|
| `herdr` | `ogulcancelik/herdr` | Claude Code + Pi |
| `find-skills` | `vercel-labs/skills` | Claude Code + Pi |
| `preflight` | `ogulcancelik/agent-skills` | Claude Code + Pi |
| `web-search` | `ogulcancelik/agent-skills` | Pi only |

Single-agent installs are copied into that agent's skills directory; multi-agent installs land in `~/.agents/skills/` and are symlinked into each agent. Update with `npx skills update -g`.

**Always pass `--agent`.** A bare `-g` installs into every agent the CLI detects, and detection only tests whether a config directory exists. Leftover directories from uninstalled agents therefore collect stray skills. Herdr has the same problem: it writes agent-state hooks for any agent whose config directory it finds.

Audit the two mechanisms with:

```sh
herdr integration status          # herdr hooks; fix with integration install/uninstall <agent>
npx skills ls -g --json           # which agents each skill is installed for
```

Only `claude` and `pi` should appear as installed. Anything else means a stale config directory under `$HOME` is being detected.

`claude/.claude/managed-settings.json` contains machine-level Claude Code safety policies. `stow.sh` prompts to install it to:
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux: `/etc/claude-code/managed-settings.json`

## Adding a new package

1. Create a directory mirroring the target path relative to `$HOME` (e.g. `foo/.config/foo/config.toml`).
2. Add the directory name to the `stow` loop in `stow.sh`.
3. Run `./stow.sh`.
