#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

BIN="$LAB_ROOT/setuid/bin/catfile"
[ -x "$BIN" ] || { fail "catfile is missing -- run: perm reset 10"; finish; exit $?; }

# Safety: catfile must never be writable by non-root, setuid or not. Look at
# the low three octal digits; the group-write (0o20) and other-write (0o02)
# bits must both be clear.
octal="$(stat -c '%a' "$BIN")"
low="$(( 8#${octal: -3} ))"
if [ $(( low & 022 )) -eq 0 ]; then
    ok "catfile is not writable by group or others"
else
    fail "catfile is writable by group or others -- run: perm reset 10"
fi

# The student genuinely cannot read /etc/shadow directly.
want_deny "you cannot read /etc/shadow directly" try_read "$STUDENT" /etc/shadow

reads_shadow() {
    local out
    out="$(sudo -n -u "$STUDENT" -H "$BIN" /etc/shadow 2>/dev/null)" || return 1
    case "$out" in root:*) return 0 ;; *) return 1 ;; esac
}
want_ok "catfile /etc/shadow prints it, starting with root:" reads_shadow

finish
