#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch03"
mkdir -p "$CH"; chown root:root "$CH"; chmod 755 "$CH"

cat > "$CH/deploy.sh" <<'TXT'
#!/bin/bash
echo "deploying to staging..."
echo "DEPLOY-OK-7731"
TXT

chown "$STUDENT" "$CH/deploy.sh"
chgrp "$(id -gn "$STUDENT")" "$CH/deploy.sh"
chmod 644 "$CH/deploy.sh"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
