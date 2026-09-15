#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch03"
F="$CH/deploy.sh"
MARKER=DEPLOY-OK-7731

[ -f "$F" ] || { fail "deploy.sh is missing -- run: perm reset 3"; finish; exit $?; }

runs_and_prints_marker() {
    local out
    out="$(sudo -n -u "$1" -H sh -c "cd '$CH' && ./deploy.sh" 2>/dev/null)" || return 1
    case "$out" in *"$MARKER"*) return 0 ;; *) return 1 ;; esac
}

want_ok   "./deploy.sh runs for you and prints its marker" runs_and_prints_marker "$STUDENT"
want_deny "niko cannot run ./deploy.sh"                    try_exec "$ENGINEER" "$F"
want_deny "nini cannot run ./deploy.sh"                    try_exec "$MANAGER"  "$F"

finish
