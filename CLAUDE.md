# Dotfiles

GNU Stow-based dotfiles repo for macOS and Linux.

## Portability

Approved changes become permanent in this repo, in the same session. Package installs go in
`install.sh`, symlinks in `stow.sh`, config in the matching stow package, and a line in this
file. Nothing stays as machine-local state. When a tool keeps its own state outside the stowed
tree (example: `herdr plugin install` writes to `~/.config/herdr/plugins/`), pin an exact
version and script the install in `install.sh`; do not leave it as a manual step.

## Structure

Each top-level directory is a stow package symlinked into `$HOME`:

- `zsh/` — `.zshrc` (Oh My Zsh, fzf, zoxide, starship, aliases, local AI functions), `.zshenv` (env vars every zsh invocation needs, e.g. `PRESENTATIONS_DIR`, `BIB_MASTER`) + `.local/bin/` scripts
- `herdr/` — `.config/herdr/config.toml` (primary terminal workspace manager, prefix `C-a`). The pinned `herdr-automatic-rename` plugin (tab auto-naming, `[N]` jump prefixes) is installed by `install.sh` and lives in herdr's own plugin dir, not in this repo
- `tmux/` — `.tmux.conf` (legacy rollback config, prefix `C-a`, TPM, flexoki dark theme)
- `kitty/` — `.config/kitty/` (gruvbox dark theme, RobotoMono Nerd Font, boots into Herdr)
- `helix/` — `.config/helix/` (gruvbox dark, REPL pipe, serpl, LSP config)
- `ruff/` — `.config/ruff/pyproject.toml` (global Ruff lint defaults)
- `claude/` —  `.claude/settings.json` (user settings: model, effort, output style, `cleanupPeriodDays`) + `.claude/managed-settings.json` (machine-level safety policies) + `.claude/output-styles/KISS.md` (the `KISS` output style, enabled by `outputStyle` in `settings.json`)
- `pi/` — `.pi/agent/` (Pi defaults and OpenCode Go model provider)
- `srt/` — `.srt-settings.json` (policy for the `sclaude`/`spi` sandbox wrappers: writes limited to `$PWD`, `/tmp` and the agents' state dirs, secret files unreadable, outbound traffic limited to an allowlist of model APIs, GitHub and package registries)
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
| `new-slides` | Scaffolds a new Quarto deck in `$PRESENTATIONS_DIR` from `templates/presentation/` |
| `slides-sync-bib` | Re-copies the Zotero master `$BIB_MASTER` over the current deck's `references.bib` |

### `.zshrc` functions

| Function | Purpose |
|---|---|
| `ai <prompt>` | Run opencode with a prompt |
| `sclaude`, `spi` | Sandboxed agents: `srt -- claude/pi` (Anthropic sandbox-runtime, pinned in `install.sh`). Seatbelt on macOS; bubblewrap + socat on Linux (distro packages, srt does not bundle them). Policy in `srt/.srt-settings.json`, stowed to `~/.srt-settings.json` |
| `sn` | Fuzzy Obsidian note search |
| `count <dir>` | Count files in a directory |

## Presentations

Quarto reveal.js decks live in `$PRESENTATIONS_DIR` (`~/Projects/cpi/presentations`). Each deck is
its own git repo and vendors the pinned `grantmcdermott/clean` extension (1.4.1).

`new-slides <folder> ["Title"]` scaffolds a deck from `templates/presentation/`:

- copies the vendored extension, `slides.qmd`, `.gitignore`, and `assets/`,
- fills the title into `slides.qmd` and `README.md`,
- seeds `references.bib` from the Zotero master `$BIB_MASTER`, or leaves it empty,
- runs `git init`.

`slides-sync-bib`, run inside a deck, re-copies `$BIB_MASTER` over `references.bib`.

`templates/` is not a stow package; it does not mirror a path under `$HOME`, so keep it out of the
`stow` loop. `PRESENTATIONS_DIR` and `BIB_MASTER` are exported from `zsh/.zshenv`, the one file
sourced by interactive shells, the `#!/bin/zsh` scripts in `.local/bin`, and the agent shell
snapshot. `stow.sh` backs up a pre-existing real `~/.zshenv` before it links.

### Zotero link

`references.bib` comes from Zotero through the Better BibTeX plugin, exported once and kept current:

1. In Zotero, right-click `My Library` (or a single collection) and choose `Export Library`.
2. Set format `Better BibTeX`, tick `Keep updated`, save as `~/Zotero/library.bib`.
3. Better BibTeX rewrites that file on every change. `new-slides` copies it into each new deck.

Citation keys follow the Better BibTeX default (`author + year`). Pin a specific item's key with
right-click, `Better BibTeX`, `Pin BibTeX key`.

## Scripts

- `install.sh` — Full bootstrap: installs brew, tools, agents, plugins, then runs `stow.sh`.
- `stow.sh` — Symlinks all packages, wires agent skills, and shares instructions across agents.



## Shared agent instructions

`claude/.claude/CLAUDE.md` holds the standing rules that apply in every project: writing, code,
figures, long jobs, delegation via herdr, and how to work with me. One tracked file, two agents:

- Claude Code reads it at `~/.claude/CLAUDE.md`, stowed by the `claude` package.
- Pi reads it at `~/.pi/agent/AGENTS.md`, symlinked to the same file by `stow.sh`.

Both agents append a project's own `CLAUDE.md` or `AGENTS.md` after the global file, so a project
can override any rule. Pi loads the first of `AGENTS.override.md`, `AGENTS.md`, `AGENTS.MD`,
`CLAUDE.md`, `CLAUDE.MD` it finds per directory, so never put two of those names in one directory.

## Agent skills

Skills come from three stores.

`agent-skills/` — **tracked in this repo. Add new skills here.** The `stow.sh` skill loop links
every subdirectory into both `~/.claude/skills/` and `~/.pi/agent/skills/`. It is not a stow
package, because it does not mirror a path under `$HOME`, so keep it out of the `stow` loop.

`~/.agent-skills/` — hand-maintained skill directories, not tracked. Legacy: prefer `agent-skills/`
above for anything new. The `stow.sh` skill loop links **every** one into both `~/.claude/skills/` and `~/.pi/agent/skills/`. This store cannot target a single agent.

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

## Agent settings files

`claude/.claude/settings.json` and `pi/.pi/agent/settings.json` are stowed as symlinks, so **both agents write straight into this repo**. Changing a setting in Claude Code or running `pi install` shows up as a `git diff` here. That is intended: it keeps settings version-controlled. Two consequences:

- Both agents rewrite key order on save, so diffs are sometimes pure reordering.
- `settings.json` holds an absolute `SessionStart` hook path (`/Users/candemircan/.claude/hooks/herdr-agent-state.sh`) written by `herdr integration install claude`. **Do not replace it with `$HOME`.** Claude Code would expand it (hooks with no `args` run through `sh -c`), but herdr matches the literal string: with `$HOME` there, `herdr integration install claude` does not recognise its own entry and appends a second identical hook, so the hook fires twice. On Linux, run `herdr integration install claude` after stowing and let herdr write the correct path.

`stow.sh` backs up a pre-existing real `settings.json` to `settings.json.bak` before it links.

`claude/.claude/managed-settings.json` contains machine-level Claude Code safety policies.

**Do not add `"disableAllHooks": true` back to it.** Managed settings outrank `settings.json`, so
that key silently kills the herdr `SessionStart` hook documented above: the hook stays on disk,
`herdr integration status` still reports `claude: current`, and nothing fires. It was set for
months without being noticed. The `permissions.deny` list and `disableBypassPermissionsMode` are
the safety policies; the hook ban was not.

`stow.sh` prompts to install it to:
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux: `/etc/claude-code/managed-settings.json`

## Adding a new package

1. Create a directory mirroring the target path relative to `$HOME` (e.g. `foo/.config/foo/config.toml`).
2. Add the directory name to the `stow` loop in `stow.sh`.
3. Run `./stow.sh`.
