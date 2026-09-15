#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

# ~/.bashrc is read by interactive shells, ~/.profile by login shells. Accept
# either, so the challenge works whichever file the student reached for.
UMASK_VAL=""
SHELL_FLAG=""
for flag in i l; do
    v="$(sudo -n -u "$STUDENT" -H env PERM_NO_GREETING=1 HOME="$STUDENT_HOME" \
            bash -"$flag"c 'umask' 2>/dev/null | tr -cd '0-7')"
    case "$v" in
        0027|027) UMASK_VAL="$v"; SHELL_FLAG="$flag"; break ;;
    esac
done

if [ -n "$UMASK_VAL" ]; then
    ok "a new shell starts with umask 0027"
else
    fail "a new shell does not start with umask 0027"
    finish; exit $?
fi

# Probe in a folder we control -- never /tmp, which on Codespaces carries a
# default ACL that overrides umask. Strip any inherited ACL too, if the acl
# tools happen to be installed (harmless no-op otherwise).
mkdir -p "$LAB_ROOT/ch08"
T="$(mktemp -d "$LAB_ROOT/ch08/probe.XXXXXX")"
setfacl -b -k "$T" >/dev/null 2>&1 || true
chown "$STUDENT" "$T"
chmod 755 "$T"          # so the negative below is about the file, not the folder

sudo -n -u "$STUDENT" -H env PERM_NO_GREETING=1 HOME="$STUDENT_HOME" \
    bash -"$SHELL_FLAG"c ": > '$T/newfile' && mkdir -p '$T/newdir'" >/dev/null 2>&1

if [ "$(mode_of "$T/newfile")" = 640 ]; then
    ok "a file you create now comes out rw-r----- (640)"
else
    fail "a file you create now comes out $(mode_of "$T/newfile") instead of 640"
fi

if [ "$(mode_of "$T/newdir")" = 750 ]; then
    ok "a folder you create now comes out rwxr-x--- (750)"
else
    fail "a folder you create now comes out $(mode_of "$T/newdir") instead of 750"
fi

want_deny "nini cannot read a file you just created" try_read "$MANAGER" "$T/newfile"

rm -rf "$T"
finish
