Here is a folder:

    /opt/lab/ch04/vault/

It has one file inside, `secret.txt`. You told niko this exact
file name. He needs to read that one file. He should not be able
to see the list of other files in the folder.

Right now he can do neither:

    sudo -u niko cat /opt/lab/ch04/vault/secret.txt
    sudo -u niko ls  /opt/lab/ch04/vault

**Your job**

  - `sudo -u niko cat /opt/lab/ch04/vault/secret.txt` works
  - `sudo -u niko ls /opt/lab/ch04/vault` still fails

The file `secret.txt` can already be read by everyone (check with
`ls -l`). The folder is what stops him.

**The idea**

On a folder, the three permission letters mean something different
than on a file:

  - `r` -- you can see the list of names inside
  - `w` -- you can add and remove names inside
  - `x` -- you can go *through* the folder to a file inside, if
           you already know its name

niko needs only one of these three.

*Challenge 4 and challenge 5 are a pair. Do 4 first, then 5. niko
here and nini in challenge 5 want opposite things from a folder
that looks the same.*
