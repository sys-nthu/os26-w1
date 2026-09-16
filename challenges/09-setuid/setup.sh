#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

BASE="$LAB_ROOT/setuid"
VAULT="$BASE/vault"
BIN="$BASE/bin"
mkdir -p "$VAULT" "$BIN"

# Rebuild checkpw if setup.sh is somehow run before the top-level build.
if [ ! -x "$BIN/checkpw" ]; then
    make -s -C "$REPO_ROOT/src" BINDIR="$BIN" all
fi

cat > "$VAULT/passwords.txt" <<'TXT'
nini:correcthorse
niko:hunter2
TXT

chown "$VAULTADM:$VAULTADM" "$VAULT/passwords.txt"
chmod 600 "$VAULT/passwords.txt"

# The student can traverse into the vault (to reach the program's target) but
# cannot list it.
chown "$VAULTADM:$VAULTADM" "$VAULT"
chmod 751 "$VAULT"

# checkpw owned by vaultadm, NOT setuid -- that is the challenge.
chown "$VAULTADM:$VAULTADM" "$BIN/checkpw"
chmod 755 "$BIN/checkpw"

chown root:root "$BASE" "$BIN"
chmod 755 "$BASE" "$BIN"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$BASE"
