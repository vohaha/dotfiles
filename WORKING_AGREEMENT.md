# Working Agreement — dotfiles

> Two-way contract between Claude and the human.
> `- [ ]` items are tracked by the enforcement script — these are one-time actions to establish.
> Ongoing behaviors live in Working Norms — no checkbox, standing contract terms.
> Either party can add to any section during a session.

---

## Current Priorities
1. Start actively using Aerospace + tmux (build muscle memory)
2. Mirror setup on Windows work machine (GlazeWM, bootstrap-windows.ps1)
3. Linux familiarity via WSL2

## Open Friction Points
- [ ] [Human] Aerospace not yet actively used — muscle memory not built — 2026-04-08
- [ ] [Human] nvim package not stowed (deferred for Linux) — 2026-04-08
- [ ] [Human] Windows side not tested — bootstrap-windows.ps1 + WSL2 + GlazeWM — 2026-04-08
- [ ] [Human] Ctrl+Left/Right and Alt+Left/Right may not work in all contexts — test in zsh vi-mode vs normal mode — 2026-04-08

## Active Commitments
- [x] [Claude] All macOS packages stowed and committed — 2026-04-08 → done
- [x] [Claude] Secrets out of repo — ~/.secrets + ~/.gitconfig.local pattern — 2026-04-08 → done
- [x] [Claude] North star in CLAUDE.md — cross-platform non-negotiable — 2026-04-08 → done
- [x] [Claude] Ansible-first bootstrap — site.yml + roles — 2026-04-08 → done
- [x] [Claude] Zed SSH connections scrubbed from history + moved to machine-local — 2026-04-08 → done

## Working Norms
- [Human] Use `/groundwork:check-in` at session end
- [Claude] Every config change must pass the north star check: does this work on macOS, Linux, and Windows?
- [Claude] When stowing a package, verify with `ls -la` that the target is a symlink — not a regular file
- [Claude] Dead weight in the repo gets flagged and removed, not just noted
- [Claude] Commit granularly per package/layer on main — branches only for tool experiments
- [Claude] Always use the groundwork commit tool, not raw git commit
- [Claude] After scrubbing git history, re-add remote manually (git-filter-repo removes it)

## What's Working
- Pre-commit hook regenerates LAYERS.md automatically — zero maintenance overhead
- The `~/.gitconfig.local` pattern keeps machine-managed tools (GCM, git-lfs) out of the repo cleanly
- Stow's `--adopt` + `git checkout -- .` pattern for syncing machine state into the repo
- Explicit package list in stow role (vs find+exclusion) — more reliable, easier to reason about
- Ansible `--check` mode as a dry-run before applying playbook changes

## Last Check-in
- Date: 2026-04-08
- Notes: Extended session — review + fixes, Ansible-first refactor, history scrub, dead file removal, keyboard shortcut fixes

---

## Resolved
- [x] Ansible playbook references nvm → replaced with fnm in localhost.yaml, then localhost.yaml removed entirely (Ansible-first)
