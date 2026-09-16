Try to run the command:

    wacow

You will see "command not found". The file exists in `/opt/lab/ch12/tools`
and it can be run. The shell simply does not know where it is.

**How the shell finds a command**

When you type the name of an executable file, the shell looks through a list of folders,
one by one, and runs the first file with that name. The list is
stored in a variable called `PATH`. Print it:

    echo $PATH

The folders are separated by `:`. Your folder is not in the list.
That is the whole problem.

To see which file a name would run, use `type -P`:

    type -P ls
    type -P wacow

The second one prints nothing.

**Your job**

  - typing `wacow` works, in every new terminal
  - `type -P wacow` prints `/opt/lab/ch12/tools/wacow`
  - it still does not work for nini. You are changing your own
    shell, not the whole machine

Do not copy or move the tool, and do not use an alias. Add the
folder to the list.

Challenge 8 showed you where a setting must go so that every new
terminal has it. This one goes in the same place.
