#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch12"
TOOLS="$CH/tools"
TOOL="$TOOLS/standup"
MARKER="STANDUP-1000-ROOM-B"

mkdir -p "$TOOLS"
chown root:root "$CH" "$TOOLS"; chmod 755 "$CH" "$TOOLS"

cat > "$TOOL" <<TXT
#!/bin/bash
echo "Standup is at 10:00 in room B."
echo "$MARKER"
TXT
chown "$STUDENT" "$TOOL"
chgrp "$(id -gn "$STUDENT")" "$TOOL"
chmod 755 "$TOOL"

# Undo the student's previous answer so the challenge starts broken again:
# any line in their shell config that mentions the tools folder.
for f in "$STUDENT_HOME/.bashrc" "$STUDENT_HOME/.profile" "$STUDENT_HOME/.bash_profile"; do
    [ -f "$f" ] || continue
    sed -i '\#/opt/lab/ch12/tools#d' "$f"
done

# And remove any copy or link of the tool that was dropped into a folder the
# shell already searches (that "solves" it for everyone, which is the point
# the negative assertion catches).
for dir in /usr/local/bin /usr/local/sbin /usr/bin /bin /usr/sbin /sbin \
           "$STUDENT_HOME/bin" "$STUDENT_HOME/.local/bin"; do
    f="$dir/standup"
    [ -e "$f" ] || [ -L "$f" ] || continue
    if grep -qs "$MARKER" "$f" 2>/dev/null || [ "$(readlink -f "$f" 2>/dev/null)" = "$TOOL" ]; then
        rm -f "$f"
    fi
done

strip_special_dirs "$CH"
