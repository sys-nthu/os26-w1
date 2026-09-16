#!/usr/bin/env bash
set -uo pipefail
# shellcheck disable=SC1091
. "${REPO_ROOT:?}/lib/common.sh"

CH="$LAB_ROOT/ch12"
TOOLS="$CH/tools"
TOOL="$TOOLS/wacow"
MESSAGE='Yeahhhh .... You make it!!!  Go eat an ice cream !!'

mkdir -p "$TOOLS"
chown root:root "$CH" "$TOOLS"; chmod 755 "$CH" "$TOOLS"

# wacow is a plain shell script: a cow says the message, in colour. It calls
# cowsay and lolcat by ABSOLUTE path on purpose -- Debian installs them in
# /usr/games, which is usually not on PATH, and this challenge is about PATH:
# the only thing that may be "not found" is wacow itself.
COWSAY="$(lookup_cmd cowsay || true)"
LOLCAT="$(lookup_cmd lolcat || true)"
if [ -n "$COWSAY" ]; then
    say_cmd="\"$COWSAY\" -W 120 \"\$MESSAGE\""
else
    say_cmd='printf "%s\\n" "$MESSAGE"'
fi
# -f: colour even when the output is not a terminal (piped to less, captured).
if [ -n "$LOLCAT" ]; then
    say_cmd="$say_cmd | \"$LOLCAT\" -f"
fi

cat > "$TOOL" <<TXT
#!/bin/bash
# wacow -- a small celebration for finishing the lab.
MESSAGE='$MESSAGE'
$say_cmd
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
    f="$dir/wacow"
    [ -e "$f" ] || [ -L "$f" ] || continue
    if grep -qs 'Go eat an ice cream' "$f" 2>/dev/null || [ "$(readlink -f "$f" 2>/dev/null)" = "$TOOL" ]; then
        rm -f "$f"
    fi
done

strip_special_dirs "$CH"
