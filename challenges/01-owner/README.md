Your private notes are here:

    /opt/lab/ch01/notes.txt

This file is yours. You own it. Try to read it:

    cat /opt/lab/ch01/notes.txt

You will see "Permission denied." This is the first lesson: owning
a file does not mean you can read it. They are two separate things.
Right now the permissions on this file allow no one to read, write,
or run it -- not even you, the owner.

There is a second problem. nini, your manager, likes to read what
is on other people's screens. These notes are not for her.

**Your job**

  - you can read the file
  - you can add new lines to the end of it
  - nini can do neither

**Look first, before you change anything**

    ls -l /opt/lab/ch01/notes.txt

The line starts with `----------`. These ten characters are the
permissions. The first one is the type (`-` means a normal file).
The other nine are three groups of three: what the owner can do,
what the group can do, and what everyone else can do. Each `-`
means "not allowed". Right now every one is a `-`.
