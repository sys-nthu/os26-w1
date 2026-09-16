Challenge 9 was the good version. This is the bad one.

Here is a program that prints any file you give it:

    /opt/lab/setuid/bin/catfile <path>

First, confirm there is a file you truly cannot read -- the real
system password hashes:

    cat /etc/shadow

You will see "Permission denied," which is correct. Now try:

    /opt/lab/setuid/bin/catfile /etc/shadow

Again "Permission denied" -- because `catfile` runs as you, and
you cannot read `/etc/shadow`.

**Your job**

Make `catfile` setuid root, the same way you made `checkpw` setuid
`vaultadm` in challenge 9. Then use it to print `/etc/shadow`:

    sudo chmod u+s /opt/lab/setuid/bin/catfile
    /opt/lab/setuid/bin/catfile /etc/shadow

It works. You just read the system password hashes as a normal
user.

**Stop and think**

`passwd` is also setuid root, it is on every Linux machine, and no
one calls it a security hole. But `catfile`, now setuid root, is
clearly a hole.

What does `catfile` do that `passwd` does not?

(The answer is in the instructor's notes. Try to answer it
yourself first -- this is the most important idea in the whole set.)

**When you are done**

Remove the bit again:

    sudo chmod u-s /opt/lab/setuid/bin/catfile

`perm reset 10` also does this. Do not leave a setuid-root
"print any file" program on the machine, even in a lab.
