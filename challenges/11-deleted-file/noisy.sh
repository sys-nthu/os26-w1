#!/usr/bin/env bash
# Appends one line per second to /tmp/lab11.log until killed. It opens the log
# once, on file descriptor 3, and keeps writing to that -- so after a student
# deletes the file, this program is still holding it open, which is the whole
# point of the challenge.
LOG=/tmp/lab11.log

exec 3>>"$LOG"          # open once, keep it open for the life of the program

n=0
while true; do
    n=$((n + 1))
    printf 'LAB11 %d %s\n' "$n" "$(date -Is 2>/dev/null || date)" >&3
    sleep 1
done
