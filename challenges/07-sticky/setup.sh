#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch07"
D="$CH/shared"
rm -rf "$D"
mkdir -p "$D"; chown root:root "$CH"; chmod 755 "$CH"

printf 'Q4 plan\n- hire one more engineer\n- move the standup to 10am\n' > "$D/nini-plan.md"
printf 'draft: cache rewrite\n- measure first\n- then do not rewrite it\n'  > "$D/niko-draft.md"

chown "$MANAGER:$MANAGER"   "$D/nini-plan.md"
chown "$ENGINEER:$ENGINEER" "$D/niko-draft.md"
chmod 644 "$D/nini-plan.md" "$D/niko-draft.md"

chown root:root "$D"
chmod 777 "$D"

# Strip any setgid/setuid/sticky inherited from a setgid ancestor (see common.sh).
strip_special_dirs "$CH"
