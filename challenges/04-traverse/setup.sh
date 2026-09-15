#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch04"
mkdir -p "$CH/vault"; chown root:root "$CH"; chmod 755 "$CH"

cat > "$CH/vault/secret.txt" <<'TXT'
the staging database password is: hunter2
(rotate this after the demo)
TXT
cat > "$CH/vault/shopping-list.txt" <<'TXT'
milk
a birthday card for niko
TXT

chown -R "$STUDENT" "$CH/vault"
chgrp -R "$(id -gn "$STUDENT")" "$CH/vault"
chmod 644 "$CH/vault/secret.txt" "$CH/vault/shopping-list.txt"
chmod 000 "$CH/vault"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
