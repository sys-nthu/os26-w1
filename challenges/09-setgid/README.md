    /opt/lab/ch09/project/

This folder belongs to the group `team`. Both nini and niko are in
`team`. They add files here every day, and then find that the other
person cannot use them. See it happen:

    sudo -u nini touch /opt/lab/ch09/project/from-nini
    sudo -u niko touch /opt/lab/ch09/project/from-niko
    ls -l /opt/lab/ch09/project/

Look at the group column. `from-nini` is in group `nini`, and
`from-niko` is in group `niko`. Neither file is in group `team`.

A new file gets the group of the person who made it, and nini and
niko each have their own personal group.

    perm reset 9

**Your job**

Every file that nini or niko creates in this folder should be in
group `team` automatically. They will not remember to run `chgrp`,
and you cannot make them.

Do not change their accounts. Change the folder. It is owned by
root, so put `sudo` in front of your command.
