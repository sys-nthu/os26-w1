#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

F="$LAB_ROOT/ch01/notes.txt"
[ -f "$F" ] || { fail "notes.txt is missing -- run: perm reset 1"; finish; exit $?; }

snapshot "$F"
want_ok   "you can read notes.txt"            try_read  "$STUDENT" "$F"
want_ok   "you can add a line to notes.txt"   try_write "$STUDENT" "$F"
want_deny "nini cannot read notes.txt"        try_read  "$MANAGER" "$F"
want_deny "nini cannot write to notes.txt"    try_write "$MANAGER" "$F"
restore

finish
