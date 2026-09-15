Nothing is broken on disk this time. Make a file and look at it:

    cd ~ && touch demo.txt && ls -l demo.txt

You will see `rw-r--r--`. Everyone on the machine can read it.
This is the default for every file you create, and until now you
have been fixing each one afterward with `chmod`.

**Your job**

Make new files that *you* create come out as `rw-r-----` from the
start: you can read and write, your group can read, everyone else
gets nothing. This must work in every new terminal, without running
`chmod`.

New folders should come out as `rwxr-x---`.

**Two things you need**

First, the command. Run it with no arguments to see the current
value:

    umask

`umask` is not a permission. It is the opposite: a list of bits to
*remove* from every new file. Your current value is `0022`, which
is why everyone-else keeps getting `r`. Work out the value that
removes one more bit.

Second, where to save it. Your shell reads this file in your home
directory every time you open a terminal:

    ~/.bashrc

Any line you add to the end of it runs in every new terminal. This
is where settings like this belong. Add the line, then **open a
new terminal** and check with `umask`.
