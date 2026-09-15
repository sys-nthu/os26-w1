#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

BIN="$LAB_ROOT/setuid/bin/checkpw"
STORE="$LAB_ROOT/setuid/vault/passwords.txt"
[ -x "$BIN" ] && [ -f "$STORE" ] || { fail "the setuid lab is missing -- run: perm reset 10"; finish; exit $?; }

grants() {   # grants <user> <pass>  -> exits 0 and prints ACCESS GRANTED
    local out
    out="$(sudo -n -u "$STUDENT" -H "$BIN" "$1" "$2" 2>/dev/null)" || return 1
    [ "$out" = "ACCESS GRANTED" ]
}
denies() {
    local out
    out="$(sudo -n -u "$STUDENT" -H "$BIN" "$1" "$2" 2>/dev/null)"
    [ "$out" = "ACCESS DENIED" ]
}

want_ok   "checkpw niko hunter2 says ACCESS GRANTED"  grants "$ENGINEER" hunter2
want_ok   "checkpw niko wrongpass says ACCESS DENIED" denies "$ENGINEER" wrongpass
want_deny "you still cannot read passwords.txt"       try_read "$STUDENT" "$STORE"

if [ "$(mode_of "$STORE")" = 600 ] && [ "$(owner_of "$STORE")" = "$VAULTADM" ]; then
    ok "passwords.txt is untouched (still 600, still $VAULTADM)"
else
    fail "passwords.txt was changed; the point was to leave it alone -- run: perm reset 10"
fi

finish
