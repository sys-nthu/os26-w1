#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

TOOL="$LAB_ROOT/ch12/tools/wacow"
PHRASE="Go eat an ice cream"
[ -x "$TOOL" ] || { fail "the wacow tool is missing -- run: perm reset 12"; finish; exit $?; }

# A fresh interactive shell for a user, with the greeting hook silenced.
new_shell() {   # new_shell <user> <command>
    local home; home="$(getent passwd "$1" | cut -d: -f6)"
    sudo -n -u "$1" -H env PERM_NO_GREETING=1 HOME="$home" bash -ic "$2" 2>/dev/null
}

strip_ansi() { sed 's/\x1b\[[0-9;]*[A-Za-z]//g'; }

# The tool itself must still be where it was and still work by full path.
prints_phrase_by_path() {
    local out; out="$(sudo -n -u "$STUDENT" -H "$TOOL" 2>/dev/null | strip_ansi)" || return 1
    case "$out" in *"$PHRASE"*) return 0 ;; *) return 1 ;; esac
}
want_ok "the tool still runs by its full path" prints_phrase_by_path

# Typing the bare name in a *new* terminal must run it.
by_name() {
    local out; out="$(new_shell "$STUDENT" 'wacow' | strip_ansi)" || return 1
    case "$out" in *"$PHRASE"*) return 0 ;; *) return 1 ;; esac
}
want_ok "typing 'wacow' works in a new terminal" by_name

# ...and it must be found through PATH, at its original location -- not via
# an alias, a function, or a copy dropped somewhere else.
resolves_to_tool() {
    [ "$(new_shell "$STUDENT" 'type -P wacow' | tail -n1)" = "$TOOL" ]
}
want_ok "'type -P wacow' prints $TOOL" resolves_to_tool

# The change is to your own shell, not to the machine: nini's new terminal
# must still not find it. (Copying the tool into /usr/local/bin fails here.)
nini_finds_it() { new_shell "$MANAGER" 'wacow' >/dev/null; }
want_deny "nini still cannot run 'wacow' by name" nini_finds_it

finish
