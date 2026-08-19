# HPC profile

A no-sudo, no-package-manager subset of these dotfiles for a shared cluster.
It reuses the real `zsh/`, `tmux/`, and `git/` configs and layers cluster-only
overrides on top, so there is one source of truth.

## Install

Run on a **login node** (compute nodes usually have no internet):

```sh
./hpc/install-hpc.sh
```

It installs into `~/.local/bin`:

- uv, ruff, ty
- starship, zoxide, fzf, ripgrep, fd, bat, git-delta, jq
- lazygit, yazi
- helix (binary plus runtime)
- Oh My Zsh, the two zsh plugins, TPM

It then links the shared configs and the `hpc/` override files, writes
`~/.hpc.local`, sets up git identity, and adds an exec-zsh hook to
`~/.bash_profile`. Agents (Claude Code, Pi) are optional; the script asks.

## What is layered

| File | Role |
|---|---|
| `~/.zshenv` -> `zsh/.zshenv` | shared env; sources `~/.zshenv.local` last |
| `~/.zshenv.local` -> `hpc/.zshenv.local` | cache relocation (uv, pip, HF) |
| `~/.zshrc` -> `zsh/.zshrc` | shared shell; sources `~/.zshrc.local` last |
| `~/.zshrc.local` -> `hpc/.zshrc.local` | SLURM aliases |
| `~/.tmux.conf` -> `tmux/.tmux.conf` | shared tmux; sources `~/.tmux.conf.local` last |
| `~/.tmux.conf.local` -> `hpc/.tmux.conf.local` | prefix `C-b`, OSC 52 clipboard |
| `~/.config/starship.toml` -> `hpc/starship.toml` | disables the cloud modules (SSH shows extra segments) |
| `~/.hpc.local` | machine-local values, **not tracked** (scratch path, module loads) |

## The real HPC traps

1. **No default-shell change.** `chsh` is often disabled. Fix: the installer
   adds a guarded `exec zsh` to `~/.bash_profile`. It only fires for interactive
   shells, so batch jobs stay in bash.
2. **Login vs compute nodes.** Compute nodes usually have no internet. Run all
   installs on a login node.
3. **Home quota.** Caches fill small home quotas fast. `~/.zshenv.local` points
   `XDG_CACHE_HOME`, `UV_CACHE_DIR`, `PIP_CACHE_DIR`, and `HF_HOME` at
   `$DOTFILES_CACHE_BASE`, which defaults to `$SCRATCH`.
4. **Missing absolute paths.** The shared `.zshenv` now guards `~/.cargo/env`
   before sourcing it. `PRESENTATIONS_DIR` and `BIB_MASTER` still point at
   laptop paths; they are inert on HPC (no script here reads them).

## Not installed here

- tmux and git: prefer the cluster's modules (`module load tmux git`). Add the
  load lines to `~/.hpc.local`, guarded with `command -v module`.
- kitty, GUI apps, Nerd Fonts: these run on your laptop, not the remote node.
- srt sandbox, herdr, managed settings: need root or user namespaces.
- `~/.local/bin` helper scripts (sessionizer, obsidian, slides): laptop-specific.
  The tmux binds `C-f`, prefix `i`, and prefix `o` therefore do nothing on HPC.
