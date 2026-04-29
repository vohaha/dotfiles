#!/usr/bin/env bash
# Runs the `nextdns` ansible role — installs nextdns (if missing), registers
# system-wide DoH resolver, and verifies via test.nextdns.io.
#
# Requires NEXTDNS_PROFILE in ~/.secrets. See docs/digital-life.md §DNS.
# Idempotent via ansible: re-run to reconfigure profile.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

# shellcheck disable=SC1091
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

if [[ -z "${NEXTDNS_PROFILE:-}" ]]; then
    cat >&2 <<EOF
error: NEXTDNS_PROFILE not set.

Add to ~/.secrets:
  export NEXTDNS_PROFILE=xxxxxx

Get profile ID from https://my.nextdns.io/ (part after "/" in URL).
EOF
    exit 1
fi

export NEXTDNS_PROFILE

exec ansible-playbook \
    -i inventory.ini \
    site.yml \
    --tags nextdns \
    --ask-become-pass
