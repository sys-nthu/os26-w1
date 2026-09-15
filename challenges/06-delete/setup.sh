#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch06"
D="$CH/dropbox"
mkdir -p "$D"; chown root:root "$CH"; chmod 755 "$CH"

cat > "$D/doomed.txt" <<'TXT'
stale build manifest -- superseded 2019
artifact: build-1183.tar.gz
TXT

chown root:root "$D" "$D/doomed.txt"
chmod 755 "$D"
chmod 444 "$D/doomed.txt"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
