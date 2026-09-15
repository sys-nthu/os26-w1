#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

D="$LAB_ROOT/ch07/shared"
NINI_FILE="$D/nini-plan.md"
NIKO_FILE="$D/niko-draft.md"
[ -f "$NINI_FILE" ] && [ -f "$NIKO_FILE" ] || {
    fail "the shared folder is missing files -- run: perm reset 7"; finish; exit $?; }

snapshot "$NINI_FILE" "$NIKO_FILE"

want_ok   "nini can create a new file in shared/" try_create "$MANAGER"  "$D/.probe-nini"
want_ok   "niko can create a new file in shared/" try_create "$ENGINEER" "$D/.probe-niko"
want_deny "nini cannot delete niko's file"        try_del    "$MANAGER"  "$NIKO_FILE"
want_deny "niko cannot delete nini's file"        try_del    "$ENGINEER" "$NINI_FILE"

rm -f "$D/.probe-nini" "$D/.probe-niko"
restore

finish
