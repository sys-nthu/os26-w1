Here are the engineering build notes:

    /opt/lab/ch02/build-notes.txt

niko, the engineer, needs to read them. He cannot yet:

    sudo -u niko cat /opt/lab/ch02/build-notes.txt

Before you change anything, look at the two people:

    groups niko
    groups nini

niko is in a group called `eng`. nini is a manager, so she is not
in `eng`. This difference is the whole point of the challenge. The
file already belongs to the `eng` group (check with `ls -l`), but
the group is not allowed to do anything yet.

**Your job**

  - niko can read the file
  - nini cannot read the file
  - niko cannot change the file
  - you can still add to it yourself

Do not change the file's owner or group. Only change what the
group is allowed to do.
