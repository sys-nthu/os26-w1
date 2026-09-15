#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

# The check needs somewhere to create test files. It must NOT be /tmp: on
# Codespaces /tmp carries a default ACL that overrides umask for new files,
# which would make this challenge unpassable. Use a folder we control.
CH="$LAB_ROOT/ch08"
mkdir -p "$CH"; chown root:root "$CH"; chmod 755 "$CH"
rm -rf "$CH"/probe.*
strip_special_dirs "$CH"

# Undo the student's previous answer so the challenge starts broken again --
# but touch only the lines this lab expects.
RC="$STUDENT_HOME/.bashrc"
PROFILE="$STUDENT_HOME/.profile"
for f in "$RC" "$PROFILE"; do
    [ -f "$f" ] || continue
    sed -i '/^[[:space:]]*umask[[:space:]]\+0\{0,1\}027[[:space:]]*$/d' "$f"
done
