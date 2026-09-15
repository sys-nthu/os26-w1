    /opt/lab/ch06/dropbox/doomed.txt

This file is old and no longer needed. nini has to delete it.
Look at it:

    ls -l /opt/lab/ch06/dropbox/

The file is read-only and owned by root. nini is not root and does
not own it. Right now she cannot delete it:

    sudo -u nini rm /opt/lab/ch06/dropbox/doomed.txt

**Your job**

Make this `rm` work for nini.

The folder is owned by root, so put `sudo` in front of your
command.

**The rule**

You may not run `chmod` or `chown` on `doomed.txt`. Leave the file
exactly as it is: mode `444`, owned by root. The check will notice
if you change it.

This looks impossible at first. It is not. Finding the answer is
the whole point of the challenge, so think about what deleting a
file really changes.
