#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/openfile"
PIDFILE="$CH/writer.pid"
LOG=/tmp/lab11.log
REC="$STUDENT_HOME/recovered.log"

[ -r "$PIDFILE" ] || { fail "the writer was never started -- run: perm start 11"; finish; exit $?; }
pid="$(cat "$PIDFILE" 2>/dev/null || true)"

# The writer leader may have exec'd or spawned the loop; accept the group.
writer_alive() {
    [ -n "${pid:-}" ] || return 1
    kill -0 "$pid" 2>/dev/null && return 0
    pgrep -f "$CH/noisy.sh" >/dev/null 2>&1
}

if writer_alive; then ok "the writer program is still running"
else fail "the writer program is not running -- run: perm start 11"; fi

if [ ! -e "$LOG" ]; then ok "/tmp/lab11.log no longer exists"
else fail "/tmp/lab11.log still exists -- you have not deleted it yet"; fi

if [ -f "$REC" ] && [ "$(owner_of "$REC")" = "$STUDENT" ]; then
    ok "~/recovered.log exists and is yours"
else
    fail "~/recovered.log is missing or not owned by you"
    finish; exit $?
fi

lines="$(grep -c 'LAB11' "$REC" 2>/dev/null || echo 0)"
if [ "$lines" -ge 10 ]; then
    ok "~/recovered.log has $lines recovered LAB11 lines (need 10)"
else
    fail "~/recovered.log has only $lines LAB11 lines (need at least 10)"
fi

finish
