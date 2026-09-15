You wrote a deploy script:

    /opt/lab/ch03/deploy.sh

Look at it. The script is fine. Now try to run it the normal way:

    cd /opt/lab/ch03
    ./deploy.sh

You will see "Permission denied." The file can be read, and the
text inside is correct. What is missing is permission to *run* it.

**Your job**

  - typing `./deploy.sh` works for you
  - niko cannot run it
  - nini cannot run it

It is your script. Only you should be able to run it.

**Try this too**

    bash /opt/lab/ch03/deploy.sh

This works right now, before you change anything. Think about why
it is different from `./deploy.sh`.
