This challenge is a guided walkthrough. Read all of it first, and
use **three terminals**. When you ran `perm start 12`, a small
program started in the background. Once per second it writes a line
like

    LAB12 42 2026-01-01T12:00:00

to the file `/tmp/lab12.log`. It is still running now.

**The situation:** the log file is about to be deleted by accident,
while the program is still writing to it. Your job is to recover
the lines afterward -- at least 10 of them -- into

    ~/recovered.log

even though the original file is gone.

---

**Terminal 1 -- watch the log grow**

    tail -f /tmp/lab12.log

Leave it running. A new line appears every second.

**Terminal 2 -- delete the file**

    rm /tmp/lab12.log

Now look at Terminal 1 again. `tail` *keeps printing new lines*.
The file no longer has a name, but the program did not notice. It
still has the file open, and that is what matters.

Check the disk too:

    df -h /tmp

The space used by the log has **not** been freed. The file is gone
from the folder, but not from the disk -- because the program still
has it open.

**Terminal 3 -- find the open file and copy it back**

Find the program. Its number was saved for you:

    cat /opt/lab/openfile/writer.pid

Every running program has a folder that lists the files it has open.
Look at this program's folder (replace PID with the number above):

    ls -l /proc/PID/fd

One entry points to your deleted log and shows `(deleted)` next to
it. It still works. Copy it back out:

    cp /proc/PID/fd/N ~/recovered.log

(where `N` is the number of that entry). Open `~/recovered.log` --
all the lines are there, including ones written right up to the
moment you copied.

**Last step -- stop the program**

    perm reset 12

Run `df -h /tmp` once more. *Now* the space is free again, because
nothing has the file open any more.

---

**The point:** `rm` removes a *name*, not a file. The data stays on
disk as long as something still has the file open. It is freed only
when the last name is gone **and** the last program using it closes
it.

One question to think about: if `rm` removes a name, what do you
think `ln` -- the command that makes a name -- does?
