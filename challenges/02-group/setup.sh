#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch02"
mkdir -p "$CH"; chown root:root "$CH"; chmod 755 "$CH"

cat > "$CH/build-notes.txt" <<'TXT'
build notes -- internal
- the nightly build needs 40 minutes, do not cancel it at 39
- staging credentials rotate on the 1st
- if the linker complains about a duplicate symbol, it is Dave's fault
TXT

chown "$STUDENT:eng" "$CH/build-notes.txt"
chmod 600 "$CH/build-notes.txt"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
