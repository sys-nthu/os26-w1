#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/openfile"
PIDFILE="$CH/writer.pid"       # the student-owned writer (for /proc recovery)
LEADFILE="$CH/leader.pid"      # the process-group leader (for a clean kill)
LOG=/tmp/lab11.log
mkdir -p "$CH"; chown root:root "$CH"; chmod 755 "$CH"

# Always stop any previous writer first. Nothing may survive a reset. We launch
# the writer in its own session (setsid), so signalling the leader's process
# group takes the whole tree -- the sudo wrapper, the student's shell, and the
# sleep it spawns.
stop_writer() {
    local pf p
    for pf in "$LEADFILE" "$PIDFILE"; do
        [ -r "$pf" ] || continue
        p="$(cat "$pf" 2>/dev/null || true)"
        [ -n "${p:-}" ] || continue
        kill -TERM -- "-$p" 2>/dev/null || kill -TERM "$p" 2>/dev/null || true
    done
    pkill -u "$STUDENT" -f "$CH/noisy.sh" 2>/dev/null || true
    sleep 0.3
    for pf in "$LEADFILE" "$PIDFILE"; do
        [ -r "$pf" ] || continue
        p="$(cat "$pf" 2>/dev/null || true)"
        [ -n "${p:-}" ] || continue
        kill -9 -- "-$p" 2>/dev/null || kill -9 "$p" 2>/dev/null || true
    done
    pkill -9 -u "$STUDENT" -f "$CH/noisy.sh" 2>/dev/null || true
    rm -f "$LEADFILE" "$PIDFILE"
}
stop_writer

# Fresh start.
rm -f "$LOG" "$STUDENT_HOME/recovered.log"

cp "$CH_DIR/noisy.sh" "$CH/noisy.sh"
chown root:root "$CH/noisy.sh"; chmod 755 "$CH/noisy.sh"

# Launch as the student, in a new session. $! is the session/group leader (the
# sudo process), which we remember only so we can kill the whole group later.
setsid sudo -n -u "$STUDENT" -H bash "$CH/noisy.sh" >/dev/null 2>&1 &
echo "$!" > "$LEADFILE"; chmod 644 "$LEADFILE"

# The process the student actually recovers from is the student-owned shell
# running noisy.sh -- find it by name so /proc/<pid>/fd is readable by them.
writer_pid=""
for _ in $(seq 1 30); do
    writer_pid="$(pgrep -u "$STUDENT" -f "$CH/noisy.sh" 2>/dev/null | head -n1)"
    [ -n "$writer_pid" ] && [ -s "$LOG" ] && break
    sleep 0.2
done
echo "${writer_pid:-}" > "$PIDFILE"; chmod 644 "$PIDFILE"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
