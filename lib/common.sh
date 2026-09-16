#!/usr/bin/env bash
# lib/common.sh -- shared helpers for `perm` and every challenge check.sh / setup.sh
#
# Sourced, never executed. Provides:
#   - configuration from /etc/perm.conf  ($REPO_ROOT $STUDENT $LAB_ROOT)
#   - the cast of characters             ($MANAGER $ENGINEER $VAULTADM)
#   - assertion helpers                  ok / fail / finish
#   - behavioural probes                 try_read / try_list / try_write / try_del / try_exec
#   - snapshot / restore so checks stay repeatable

PERM_CONF="${PERM_CONF:-/etc/perm.conf}"
if [ -r "$PERM_CONF" ]; then
    # shellcheck disable=SC1090
    . "$PERM_CONF"
fi

LAB_ROOT="${LAB_ROOT:-/opt/lab}"

# The cast. Scripts refer to $MANAGER / $ENGINEER so the names can be changed in
# one place; student-facing prose spells them out literally.
MANAGER=nini
ENGINEER=niko
VAULTADM=vaultadm

export LAB_ROOT MANAGER ENGINEER VAULTADM STUDENT REPO_ROOT

# Home directory of the student account (perm runs as root, so ~ is wrong).
if [ -n "${STUDENT:-}" ]; then
    STUDENT_HOME="$(getent passwd "$STUDENT" 2>/dev/null | cut -d: -f6)"
    : "${STUDENT_HOME:=/home/$STUDENT}"
    export STUDENT_HOME
fi

# ---------------------------------------------------------------- colours ---
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
    C_GREEN=$'\033[0;32m'; C_RED=$'\033[0;31m'; C_YELLOW=$'\033[0;33m'
    C_BOLD=$'\033[1m';     C_DIM=$'\033[2m';    C_OFF=$'\033[0m'
else
    C_GREEN=''; C_RED=''; C_YELLOW=''; C_BOLD=''; C_DIM=''; C_OFF=''
fi
export C_GREEN C_RED C_YELLOW C_BOLD C_DIM C_OFF

# ------------------------------------------------------------- assertions ---
PERM_FAILED=0

ok()   { printf '  %s✓%s %s\n' "$C_GREEN" "$C_OFF" "$1"; }
fail() { printf '  %s✗%s %s\n' "$C_RED" "$C_OFF" "$1"; PERM_FAILED=1; }

# assert <condition-exit-status-already-evaluated> is awkward in bash, so the
# checks use these two wrappers instead:
#   want_ok   "description"   <command...>     -> command must succeed
#   want_deny "description"   <command...>     -> command must fail
want_ok() {
    local desc="$1"; shift
    if "$@"; then ok "$desc"; else fail "$desc"; fi
}
want_deny() {
    local desc="$1"; shift
    if "$@"; then fail "$desc"; else ok "$desc"; fi
}

finish() {
    if [ "$PERM_FAILED" -eq 0 ]; then
        return 0
    fi
    return 1
}

# --------------------------------------------------------------- probes -----
# Every one of these runs a real command as a real user. Checks must never
# compare mode bits to an expected number.
as_user()   { sudo -n -u "$1" -H "${@:2}"; }

try_read()  { sudo -n -u "$1" -H cat            "$2" >/dev/null 2>&1; }
try_list()  { sudo -n -u "$1" -H ls             "$2" >/dev/null 2>&1; }
try_stat()  { sudo -n -u "$1" -H ls -l          "$2" >/dev/null 2>&1; }
try_write() { sudo -n -u "$1" -H sh -c "echo perm-probe >> '$2'" >/dev/null 2>&1; }
try_del()   { sudo -n -u "$1" -H rm -f          "$2" >/dev/null 2>&1; }
try_create(){ sudo -n -u "$1" -H touch          "$2" >/dev/null 2>&1; }
try_exec()  { sudo -n -u "$1" -H sh -c "cd '$(dirname "$2")' && ./'$(basename "$2")'" >/dev/null 2>&1; }

# Run something as the student in an *interactive* shell (so ~/.bashrc applies).
# PERM_NO_GREETING stops the .bashrc progress board from recursing into us.
as_student_interactive() {
    sudo -n -u "$STUDENT" -H env PERM_NO_GREETING=1 HOME="$STUDENT_HOME" bash -ic "$1" 2>/dev/null
}
as_student_login() {
    sudo -n -u "$STUDENT" -H env PERM_NO_GREETING=1 HOME="$STUDENT_HOME" bash -lc "$1" 2>/dev/null
}

# ------------------------------------------------- non-destructive checks ---
# Checks have to poke at files to learn anything, so they save and restore.
PERM_SNAP_DIR=""
snapshot() {
    # snapshot <file> ...   -- remember content+owner+mode of each file
    [ -n "$PERM_SNAP_DIR" ] || PERM_SNAP_DIR="$(mktemp -d)"
    local f i=0
    for f in "$@"; do
        i=$((i + 1))
        [ -e "$f" ] || continue
        cp -a "$f" "$PERM_SNAP_DIR/snap.$i"
        printf '%s\n' "$f" > "$PERM_SNAP_DIR/path.$i"
    done
}
restore() {
    [ -n "$PERM_SNAP_DIR" ] || return 0
    local p f
    for p in "$PERM_SNAP_DIR"/path.*; do
        [ -e "$p" ] || continue
        f="$(cat "$p")"
        cp -a --no-target-directory "${p/path./snap.}" "$f"
    done
    rm -rf "$PERM_SNAP_DIR"
    PERM_SNAP_DIR=""
}

# Print mode / owner / group of a path, for the few places where the *rule* of
# the challenge is "do not touch this file" rather than "make this work".
mode_of()  { stat -c '%a' "$1" 2>/dev/null; }
owner_of() { stat -c '%U' "$1" 2>/dev/null; }
group_of() { stat -c '%G' "$1" 2>/dev/null; }

# Force a directory to a plain permission mode with NO setuid/setgid/sticky bit.
# GNU chmod keeps those bits on a directory even when given a numeric mode, and
# on some images (Codespaces) /opt is setgid, so every directory created under
# it inherits the setgid bit -- which would silently pre-solve the setgid
# challenge and skew group ownership everywhere. Strip them explicitly.
strip_special_dirs() {  # strip_special_dirs <dir> ...  (recurses into each)
    local d
    for d in "$@"; do
        [ -d "$d" ] || continue
        find "$d" -type d -exec chmod u-s,g-s,-t {} + 2>/dev/null || true
    done
}

# Absolute path of a command, also checking the game directories Debian uses
# for cowsay/lolcat (not on most PATHs). Prints the path; fails if not found.
lookup_cmd() {
    local p
    if p="$(command -v "$1" 2>/dev/null)" && [ -x "$p" ]; then printf '%s\n' "$p"; return 0; fi
    for p in "/usr/games/$1" "/usr/local/games/$1" "/usr/local/bin/$1" "/usr/bin/$1"; do
        [ -x "$p" ] && { printf '%s\n' "$p"; return 0; }
    done
    return 1
}

die() { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }
