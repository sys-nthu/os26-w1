#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

D="$LAB_ROOT/ch04/vault"
F="$D/secret.txt"
[ -d "$D" ] && [ -f "$F" ] || { fail "the vault is missing -- run: perm reset 4"; finish; exit $?; }

want_ok   "niko can read vault/secret.txt"   try_read "$ENGINEER" "$F"
want_deny "niko cannot list the vault"       try_list "$ENGINEER" "$D"
want_ok   "you can still list the vault"     try_list "$STUDENT"  "$D"

finish
