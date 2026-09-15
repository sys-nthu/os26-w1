#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

D="$LAB_ROOT/ch09/project"
[ -d "$D" ] || { fail "the project folder is missing -- run: perm reset 9"; finish; exit $?; }

lands_in_team() {          # lands_in_team <user> <name>
    local u="$1" f="$D/$2" g
    rm -f "$f"
    sudo -n -u "$u" -H touch "$f" >/dev/null 2>&1 || { rm -f "$f"; return 1; }
    g="$(group_of "$f")"
    rm -f "$f"
    [ "$g" = team ]
}

want_ok   "a file nini creates here lands in group team"  lands_in_team "$MANAGER"  .probe-nini
want_ok   "a file niko creates here lands in group team"  lands_in_team "$ENGINEER" .probe-niko
# You are the sysadmin, not a member of team -- the folder is still theirs.
want_deny "you are still not able to create files here"   try_create "$STUDENT" "$D/.probe-you"

rm -f "$D/.probe-nini" "$D/.probe-niko" "$D/.probe-you"
finish
