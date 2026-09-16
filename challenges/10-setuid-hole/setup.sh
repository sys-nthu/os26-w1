#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

BASE="$LAB_ROOT/setuid"
BIN="$BASE/bin"
mkdir -p "$BIN"

if [ ! -x "$BIN/catfile" ]; then
    make -s -C "$REPO_ROOT/src" BINDIR="$BIN" all
fi

# root-owned, 755, and crucially NOT setuid: reset always strips the bit so the
# challenge starts closed and never leaves a hole open.
chown root:root "$BIN/catfile"
chmod 755 "$BIN/catfile"

chown root:root "$BASE" "$BIN"
chmod 755 "$BASE" "$BIN"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$BASE"
