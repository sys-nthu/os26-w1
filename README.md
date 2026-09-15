# Linux Permissions Playground

This playground contains 12 small Linux permission exercises.

In each exercise, some files or directories start with the wrong permissions. Your job is to fix them using `chmod` so that the required users can access them, while other users cannot.

You do **not** need to write any programs. Everything needed for the exercises is already installed.

## Setup

Run the setup script once when you first open the Codespace:

```bash
sudo ./setup.sh
```

After setup finishes, **open a new terminal**.

You should see something like:

```text
Linux permissions playground

  1  ✗  Your own file
  2  ✗  Engineers only
  ...
  0 of 12 solved.
```

The playground is controlled using the `perm` command.

## Commands

| Command          | Description                                                       |
| ---------------- | ----------------------------------------------------------------- |
| `perm`           | Show all challenges and your current progress.                    |
| `perm start 1`   | Start challenge 1 and show its instructions.                      |
| `perm check 1`   | Check whether your permissions are correct.                       |
| `perm hint 1`    | Show a hint for challenge 1. Repeated hints become more specific. |
| `perm reset 1`   | Reset challenge 1 to its original state.                          |
| `perm reset all` | Reset all challenges.                                             |
| `perm status`    | Show how many challenges you have completed.                      |

For example:

```bash
perm start 3
```

Read the problem, inspect the files, change their permissions, and then run:

```bash
perm check 3
```

If your solution is wrong, inspect the permissions again and try to understand why. Use `perm hint 3` if you need help.

## Users in the exercises

Most exercises involve two users:

* `nini` — manager
* `niko` — engineer

You are acting as the system administrator. Your goal is to configure the permissions required by the problem.

## Linux's Permission Model

Use `ls -l` to inspect a file:

```bash
ls -l somefile
```

For example:

```text
-rw-r--r--
```

The permission bits are divided into three groups:

```text
-rw-r--r--
 │  │  │
 │  │  └── others
 │  └───── group
 └──────── owner
```

Within each group:

* `r` = read
* `w` = write
* `x` = execute

The numeric values are:

```text
r = 4
w = 2
x = 1
```

So:

```bash
chmod 640 somefile
```

means:

```text
owner:  read + write   (6)
group:  read           (4)
others: no permission  (0)
```

You do not need to know everything about Linux permissions before starting. Later challenges will introduce directory permissions and special permission bits.

## Resetting a challenge

If you want to start a challenge again:

```bash
perm reset 4
```

To reset everything:

```bash
perm reset all
```

If `perm` tells you to run `sudo ./setup.sh`, the playground has not been initialized, or the Codespace has been rebuilt. Run the setup script again.

## Start

Begin with:

```bash
perm start 1
```
