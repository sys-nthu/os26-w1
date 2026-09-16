#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

TOOL="$LAB_ROOT/ch12/tools/standup"
MARKER="STANDUP-1000-ROOM-B"
[ -x "$TOOL" ] || { fail "the standup tool is missing -- run: perm reset 12"; finish; exit $?; }

# A fresh interactive shell for a user, with the greeting hook silenced.
new_shell() {   # new_shell <user> <command>
    local home; home="$(getent passwd "$1" | cut -d: -f6)"
    sudo -n -u "$1" -H env PERM_NO_GREETING=1 HOME="$home" bash -ic "$2" 2>/dev/null
}

# The tool itself must still be where it was and still work by full path.
prints_marker_by_path() {
    local out; out="$(sudo -n -u "$STUDENT" -H "$TOOL" 2>/dev/null)" || return 1
    case "$out" in *"$MARKER"*) return 0 ;; *) return 1 ;; esac
}
want_ok "the tool still runs by its full path" prints_marker_by_path

# Typing the bare name in a *new* terminal must run it.
by_name() {
    local out; out="$(new_shell "$STUDENT" 'standup')" || return 1
    case "$out" in *"$MARKER"*) return 0 ;; *) return 1 ;; esac
}
want_ok "typing 'standup' works in a new terminal" by_name

# ...and it must be found through PATH, at its original location -- not via
# an alias, a function, or a copy dropped somewhere else.
resolves_to_tool() {
    [ "$(new_shell "$STUDENT" 'type -P standup' | tail -n1)" = "$TOOL" ]
}
want_ok "'type -P standup' prints $TOOL" resolves_to_tool

# The change is to your own shell, not to the machine: nini's new terminal
# must still not find it. (Copying the tool into /usr/local/bin fails here.)
nini_finds_it() { new_shell "$MANAGER" 'standup' >/dev/null; }
want_deny "nini still cannot run 'standup' by name" nini_finds_it

finish
