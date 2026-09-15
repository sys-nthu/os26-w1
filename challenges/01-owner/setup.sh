#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch01"
mkdir -p "$CH"; chown root:root "$CH"; chmod 755 "$CH"

cat > "$CH/notes.txt" <<'TXT'
standup notes, week 1
- ask niko where the deploy script went
- nini wants the Q3 numbers by Friday (stall)
- the coffee machine needs descaling again
TXT

chown "$STUDENT" "$CH/notes.txt"
chgrp "$(id -gn "$STUDENT")" "$CH/notes.txt"
chmod 000 "$CH/notes.txt"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
