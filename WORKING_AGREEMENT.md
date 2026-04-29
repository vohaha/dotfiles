# Working Agreement — dotfiles

> Two-way contract between Claude and the human.
> `- [ ]` items are tracked by the enforcement script — these are one-time actions to establish.
> Ongoing behaviors live in Working Norms — no checkbox, standing contract terms.
> Either party can add to any section during a session.

---

## Current Priorities
1. Build tmux muscle memory
2. Mirror setup on Windows work machine (GlazeWM, bootstrap-windows.ps1)
3. Linux familiarity via WSL2

## Open Friction Points
- [ ] [Human] nvim package not stowed (deferred for Linux)
- [ ] [Human] Windows side not tested — bootstrap-windows.ps1 + WSL2 + GlazeWM
- [ ] [Human] Ctrl+Left/Right and Alt+Left/Right may not work in all contexts — test in zsh vi-mode vs normal mode
- [ ] [Human] iPhone NextDNS install (Dashboard → Setup → Apple → `.mobileconfig` → AirDrop → install)

## Active Commitments
*(none yet — fresh start 2026-04-29)*

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
- Stow's `--adopt` + scoped `git checkout -- <pkg>/` for syncing machine state into the repo
- Explicit package list in stow role (vs find+exclusion) — more reliable, easier to reason about
- Ansible `--check` mode as a dry-run before applying playbook changes
- Gated roles via `when: ansible_env.X is defined` let optional features (e.g. `nextdns`) live in `site.yml` without forcing everyone to set up the secret — bootstrap passes cleanly either way
- `bootstrap.sh doctor` for read-only verify; CI on every PR (lint + Ubuntu bootstrap), macOS bootstrap on weekly cron

## Last Check-in
- Date: 2026-04-29
- Notes: Fresh repo init — history dropped to remove sensitive content; current working state preserved as new initial commit.
