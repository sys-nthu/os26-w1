You wrote a small tool:

    /opt/lab/ch12/tools/standup

Run it with its full path:

    /opt/lab/ch12/tools/standup

It works. Now try to run it by name only, the way you run `ls`:

    standup

You will see "command not found". The file exists and it can be
run. The shell simply does not know where to look for it.

**How the shell finds a command**

When you type a name, the shell looks through a list of folders,
one by one, and runs the first file with that name. The list is
stored in a variable called `PATH`. Print it:

    echo $PATH

The folders are separated by `:`. Your folder is not in the list.
That is the whole problem.

To see which file a name would run, use `type -P`:

    type -P ls
    type -P standup

The second one prints nothing.

**Your job**

  - typing `standup` works, in every new terminal
  - `type -P standup` prints `/opt/lab/ch12/tools/standup`
  - it still does not work for nini -- you are changing your own
    shell, not the whole machine

Do not copy or move the tool, and do not use an alias. Add the
folder to the list.

Challenge 8 showed you where a setting must go so that every new
terminal has it. This one goes in the same place.
