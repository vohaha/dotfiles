# Working Agreement — dotfiles

> Two-way contract between Claude and the human.
> `- [ ]` items are tracked by the enforcement script — these are one-time actions to establish.
> Ongoing behaviors live in Working Norms — no checkbox, standing contract terms.
> Either party can add to any section during a session.

---

## Current Priorities
1. Get macOS setup fully working and habitual (Aerospace, tmux, keyboard-first)
2. Mirror setup on Windows work machine
3. Linux familiarity via WSL2 and eventually a dedicated machine

## Open Friction Points
- [ ] [Human] Aerospace not yet actively used — muscle memory not built — 2026-04-08
- [ ] [Human] nvim package not stowed (deferred, but should be tracked) — 2026-04-08
- [ ] [Human] Windows side not started — bootstrap-windows.ps1 and GlazeWM — 2026-04-08
- [ ] [Human] Ansible playbook references nvm (removed) — needs update — 2026-04-08

## Active Commitments
- [x] [Claude] All macOS packages stowed and committed — 2026-04-08 → done
- [x] [Claude] Secrets out of repo — ~/.secrets + ~/.gitconfig.local pattern — 2026-04-08 → done
- [x] [Claude] North star in CLAUDE.md — cross-platform non-negotiable — 2026-04-08 → done

## Working Norms
- [Human] Use `/groundwork:check-in` at session end
- [Claude] Every config change must pass the north star check: does this work on macOS, Linux, and Windows?
- [Claude] When stowing a package, verify with `ls -la` that the target is a symlink — not a regular file
- [Claude] Dead weight in the repo gets flagged and removed, not just noted
- [Claude] Commit granularly per package/layer on main — branches only for tool experiments

## What's Working
- Pre-commit hook regenerates LAYERS.md automatically — zero maintenance overhead
- The `~/.gitconfig.local` pattern keeps machine-managed tools (GCM, git-lfs) out of the repo cleanly
- Stow's `--adopt` + `git checkout -- .` pattern for syncing machine state into the repo

## Last Check-in
- Date: 2026-04-08
- Notes: First real session — established foundation, stowed all macOS packages, built infrastructure (LAYERS.md generator, pre-commit hook, secrets pattern)

---

## Resolved
