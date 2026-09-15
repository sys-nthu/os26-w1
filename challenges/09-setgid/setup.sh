#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch09"
D="$CH/project"
rm -rf "$D"
mkdir -p "$D"; chown root:root "$CH"; chmod 755 "$CH"

chown root:team "$D"
chmod 775 "$D"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
