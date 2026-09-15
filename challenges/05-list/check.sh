#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

D="$LAB_ROOT/ch05/vault"
F="$D/secret.txt"
[ -d "$D" ] && [ -f "$F" ] || { fail "the vault is missing -- run: perm reset 5"; finish; exit $?; }

want_ok   "nini can list the vault"            try_list "$MANAGER" "$D"
want_deny "nini cannot read vault/secret.txt"  try_read "$MANAGER" "$F"
want_ok   "you can still read vault/secret.txt" try_read "$STUDENT" "$F"

finish
