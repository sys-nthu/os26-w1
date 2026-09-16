This is a small version of how `passwd` works.

Here is a password file you are not allowed to read:

    /opt/lab/setuid/vault/passwords.txt

Check:

    cat /opt/lab/setuid/vault/passwords.txt

You will see "Permission denied." The file belongs to a service
account, `vaultadm`, and only `vaultadm` can read it.

There is also a small program that checks a password against that
file:

    /opt/lab/setuid/bin/checkpw <user> <password>

It also belongs to `vaultadm`. Run it:

    /opt/lab/setuid/bin/checkpw niko hunter2

    checkpw: cannot open password store

It failed. *You* ran the program, and you cannot open the file, so
the program cannot open it either while it runs as you.

**Your job**

Without changing anything about `passwords.txt`, make `checkpw`
able to open the file, so that:

    /opt/lab/setuid/bin/checkpw niko hunter2      says ACCESS GRANTED
    /opt/lab/setuid/bin/checkpw niko wrongpass    says ACCESS DENIED

And after that, you *still* cannot read `passwords.txt` yourself.
You will have given the program an ability without giving yourself
the permission.

**Warm-up**

    find /usr/bin /bin -perm -4000 -type f

These are the programs on this machine that already do what you are
about to do. You will see `passwd`, `sudo`, and a few others.

**A common mistake**

**Linux ignores this setting on `#!` scripts.** If you try it on a
bash script, nothing happens -- Linux always ignores it for
scripts. It only works on a real compiled program like `checkpw`.
Do not waste time trying it on a script.

**The comparison**

  - `checkpw` is like `passwd`
  - `passwords.txt` is like `/etc/shadow`
  - `vaultadm` is like `root`

`passwd` lets you change your password, which is stored in a file
you cannot read or write. It does this with the same bit you are
about to set.
