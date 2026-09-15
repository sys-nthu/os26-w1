Another folder, the same shape:

    /opt/lab/ch05/vault/

nini is doing an audit. She needs to see **which files exist** in
the folder. She must not read what is inside any of them.

This is the opposite of challenge 4. There, niko knew a file name
and needed to reach past the folder. Here, nini needs the list of
names and nothing more.

**Your job**

  - `sudo -u nini ls /opt/lab/ch05/vault` works
  - `sudo -u nini cat /opt/lab/ch05/vault/secret.txt` still fails

**After it works, try this**

    sudo -u nini ls    /opt/lab/ch05/vault
    sudo -u nini ls -l /opt/lab/ch05/vault

These two act differently, and that difference is the point. Plain
`ls` only reads the list of names. `ls -l` must open each file to
read its size and date -- and opening the files is exactly what
nini is not allowed to do.
