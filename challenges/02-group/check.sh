#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

F="$LAB_ROOT/ch02/build-notes.txt"
[ -f "$F" ] || { fail "build-notes.txt is missing -- run: perm reset 2"; finish; exit $?; }

if [ "$(group_of "$F")" != "eng" ]; then
    fail "build-notes.txt no longer belongs to the eng group -- run: perm reset 2"
    finish; exit $?
fi

snapshot "$F"
want_ok   "niko can read build-notes.txt"        try_read  "$ENGINEER" "$F"
want_deny "nini cannot read build-notes.txt"     try_read  "$MANAGER"  "$F"
want_deny "niko cannot change build-notes.txt"   try_write "$ENGINEER" "$F"
want_ok   "you can still add to build-notes.txt" try_write "$STUDENT"  "$F"
restore

finish
