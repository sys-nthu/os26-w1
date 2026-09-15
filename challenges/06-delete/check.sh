#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

D="$LAB_ROOT/ch06/dropbox"
F="$D/doomed.txt"
[ -f "$F" ] || { fail "doomed.txt is missing -- run: perm reset 6"; finish; exit $?; }

# The rule of this challenge is "leave the file alone", so here -- and only
# here -- the check looks at the file's own bits.
if [ "$(mode_of "$F")" = 444 ] && [ "$(owner_of "$F")" = root ] && [ "$(group_of "$F")" = root ]; then
    ok "doomed.txt was left alone (still 444, still root:root)"
else
    fail "you changed doomed.txt itself; the rule was to leave it alone -- run: perm reset 6"
fi

# Save it, let nini try, put it back exactly as it was.
snapshot "$F"
if try_del "$MANAGER" "$F" && [ ! -e "$F" ]; then
    ok "nini can delete doomed.txt"
else
    fail "nini still cannot delete doomed.txt"
fi
restore

finish
