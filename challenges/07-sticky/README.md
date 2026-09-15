    /opt/lab/ch07/shared/

This is a shared folder. nini and niko both use it, and both need
to keep adding new files. Look at what is inside now:

    ls -l /opt/lab/ch07/shared/

One file belongs to nini, one to niko. Last week nini deleted
niko's file by accident. Right now she can do it again:

    sudo -u nini rm /opt/lab/ch07/shared/niko-draft.md

(Try it. `perm reset 7` puts the file back.)

**Your job**

  - nini can still create new files here
  - niko can still create new files here
  - nini cannot delete niko's file
  - niko cannot delete nini's file

Keep it a shared folder. Only stop them from deleting each other's
files. The folder is owned by root, so put `sudo` in front of your
command.

**Look at this**

    ls -ld /tmp

`/tmp` has the same problem -- every program writes files there --
and it is already solved. Look at the last character of the
permissions. It is not `x`, and it is not `-`. Find out what it is.
