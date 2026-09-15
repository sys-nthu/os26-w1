#!/usr/bin/env bash
# setup.sh -- one-time bootstrap for the Linux permissions playground.
#
#   sudo ./setup.sh              install (idempotent, safe to re-run)
#   sudo ./setup.sh --refresh    reinstall and reset every challenge
#   sudo ./setup.sh --uninstall  remove accounts, /opt/lab, perm, bashrc hook
#
# Designed for a GitHub Codespace on the default image: no devcontainer, no
# image build, under a minute on a warm container.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_ROOT=/opt/lab
PERM_CONF=/etc/perm.conf
BASHRC_MARK='# >>> linux-shell-playground >>>'

MANAGER=nini
ENGINEER=niko
VAULTADM=vaultadm

if [ -t 1 ]; then
    B=$'\033[1m'; G=$'\033[0;32m'; R=$'\033[0;31m'; Y=$'\033[0;33m'; O=$'\033[0m'
else
    B=''; G=''; R=''; Y=''; O=''
fi

say()  { printf '%s==>%s %s\n' "$B" "$O" "$*"; }
warn() { printf '%swarn:%s %s\n' "$Y" "$O" "$*" >&2; }
die()  { printf '\n%serror:%s %s\n\n' "$R" "$O" "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "run this with sudo:  sudo ./setup.sh"

MODE=install
case "${1:-}" in
    '')            MODE=install ;;
    --refresh)     MODE=refresh ;;
    --uninstall)   MODE=uninstall ;;
    -h|--help)     sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)             die "unknown option '$1' (try --help)" ;;
esac

# The account name differs between images (codespace, vscode, ...). Resolve it
# once, here, and never hardcode it anywhere else.
STUDENT="${SUDO_USER:-$(logname 2>/dev/null || echo vscode)}"
if [ "$STUDENT" = root ]; then
    die "the student account resolved to 'root', which is never right (root
       bypasses every permission, so no challenge would work).

       Run this from your normal account:  sudo ./setup.sh
       or set the account explicitly:       sudo SUDO_USER=<you> ./setup.sh"
fi

# --------------------------------------------------------------------------
# uninstall
# --------------------------------------------------------------------------
if [ "$MODE" = uninstall ]; then
    say "Stopping any background lab processes"
    for pf in "$LAB_ROOT/openfile/leader.pid" "$LAB_ROOT/openfile/writer.pid"; do
        [ -r "$pf" ] || continue
        pid="$(cat "$pf" 2>/dev/null || true)"
        [ -n "${pid:-}" ] || continue
        kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
    done
    pkill -f "$LAB_ROOT/openfile/noisy.sh" 2>/dev/null || true
    sleep 0.3
    pkill -9 -f "$LAB_ROOT/openfile/noisy.sh" 2>/dev/null || true

    say "Removing lab state"
    rm -rf "$LAB_ROOT" "$PERM_CONF" /usr/local/bin/perm /tmp/lab12.log /etc/sudoers.d/perm-lab

    student_home="$(getent passwd "$STUDENT" 2>/dev/null | cut -d: -f6 || true)"
    if [ -n "${student_home:-}" ] && [ -f "$student_home/.bashrc" ]; then
        say "Removing the .bashrc hook"
        sed -i '/^# >>> linux-shell-playground >>>$/,/^# <<< linux-shell-playground <<<$/d' \
            "$student_home/.bashrc"
    fi
    rm -rf "${student_home:-/nonexistent}/.perm" "${student_home:-/nonexistent}/recovered.log"

    say "Removing lab accounts"
    for u in "$MANAGER" "$ENGINEER" "$VAULTADM"; do
        if id -u "$u" >/dev/null 2>&1; then
            pkill -9 -u "$u" 2>/dev/null || true
            userdel -r "$u" >/dev/null 2>&1 || userdel "$u" >/dev/null 2>&1 || true
        fi
    done
    for g in eng team "$MANAGER" "$ENGINEER" "$VAULTADM"; do
        getent group "$g" >/dev/null 2>&1 && groupdel "$g" >/dev/null 2>&1 || true
    done
    printf '\n%sUninstalled.%s\n\n' "$G" "$O"
    exit 0
fi

# --------------------------------------------------------------------------
# 1. tools
# --------------------------------------------------------------------------
say "Checking for required tools"
missing=()
need_tool() { command -v "$1" >/dev/null 2>&1 || missing+=("$2"); }
need_tool gcc      gcc
need_tool make     make
need_tool lsof     lsof
need_tool ps       procps
need_tool findmnt  util-linux
need_tool stat     coreutils
need_tool sudo     sudo
need_tool useradd  passwd

if [ "${#missing[@]}" -gt 0 ]; then
    say "Installing: ${missing[*]}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq --no-install-recommends "${missing[@]}"
else
    say "  all present, skipping apt"
fi

# gcc without the C headers is useless for the setuid probe and the lab
# binaries, and some minimal images ship one without the other. Confirm gcc can
# actually compile, and pull in the headers if it cannot.
if ! echo 'int main(void){return 0;}' | gcc -x c -o /dev/null - >/dev/null 2>&1; then
    say "gcc cannot find the C headers; installing libc6-dev"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq --no-install-recommends libc6-dev
    echo 'int main(void){return 0;}' | gcc -x c -o /dev/null - >/dev/null 2>&1 \
        || die "gcc still cannot compile a trivial program; cannot build the lab binaries."
fi

# --------------------------------------------------------------------------
# 2. the cast
# --------------------------------------------------------------------------
say "Creating lab accounts"
id -u "$STUDENT" >/dev/null 2>&1 || die "student account '$STUDENT' does not exist"

for g in eng team; do
    getent group "$g" >/dev/null 2>&1 || groupadd "$g"
done

make_person() {   # make_person <name>
    local u="$1"
    if ! id -u "$u" >/dev/null 2>&1; then
        useradd --create-home --home-dir "/home/$u" --shell /bin/bash "$u"
        passwd -l "$u" >/dev/null 2>&1 || true
    fi
    rm -f "/var/mail/$u" "/var/spool/mail/$u" 2>/dev/null || true
}

make_person "$MANAGER"
make_person "$ENGINEER"

# nini manages, niko engineers. Only niko is in eng -- that gap is what makes
# challenge 2 teachable. Both are in team.
usermod -aG team "$MANAGER"
usermod -aG eng,team "$ENGINEER"

NOLOGIN=/usr/sbin/nologin
[ -x "$NOLOGIN" ] || NOLOGIN=/sbin/nologin
[ -x "$NOLOGIN" ] || NOLOGIN=/bin/false
getent group "$VAULTADM" >/dev/null 2>&1 || groupadd --system "$VAULTADM"
id -u "$VAULTADM" >/dev/null 2>&1 || \
    useradd --system --gid "$VAULTADM" --no-create-home \
            --home-dir /nonexistent --shell "$NOLOGIN" "$VAULTADM"

# The student is the sysadmin, not a team member. If they are in either group,
# half the negative assertions in the lab become unsatisfiable.
if id -nG "$STUDENT" | tr ' ' '\n' | grep -qx -e eng -e team; then
    die "the account '$STUDENT' is a member of 'eng' and/or 'team'.
       The lab needs it to be in neither. Remove it and re-run:

           sudo gpasswd -d $STUDENT eng
           sudo gpasswd -d $STUDENT team
           sudo ./setup.sh"
fi

# --------------------------------------------------------------------------
# 3. /opt/lab, and the two things that silently break setuid
# --------------------------------------------------------------------------
if [ "$MODE" = refresh ]; then
    say "Refresh: discarding all existing lab state"
    for pf in "$LAB_ROOT/openfile/leader.pid" "$LAB_ROOT/openfile/writer.pid"; do
        [ -r "$pf" ] || continue
        pid="$(cat "$pf" 2>/dev/null || true)"
        [ -n "${pid:-}" ] && kill -TERM -- "-$pid" 2>/dev/null || true
    done
    pkill -f "$LAB_ROOT/openfile/noisy.sh" 2>/dev/null || true
    rm -rf "$LAB_ROOT" /tmp/lab12.log
fi

say "Preparing $LAB_ROOT"
mkdir -p "$LAB_ROOT"
chown root:root "$LAB_ROOT"
chmod 755 "$LAB_ROOT"

if findmnt -no OPTIONS -T "$LAB_ROOT" | tr ',' '\n' | grep -qx nosuid; then
    die "the filesystem holding $LAB_ROOT is mounted 'nosuid', so challenges 10
       and 11 could never work. This lab cannot run here.

       $(findmnt -no SOURCE,TARGET,OPTIONS -T "$LAB_ROOT")"
fi

say "Probing that setuid really elevates here"
probe_src="$LAB_ROOT/.suid-probe.c"
probe_bin="$LAB_ROOT/.suid-probe"
cat > "$probe_src" <<'PROBE'
#include <stdio.h>
#include <unistd.h>
int main(void) { printf("%u\n", (unsigned) geteuid()); return 0; }
PROBE
gcc -O0 -o "$probe_bin" "$probe_src"
chown root:root "$probe_bin"
chmod 4755 "$probe_bin"
probe_out="$(sudo -n -u "$STUDENT" "$probe_bin" 2>/dev/null || true)"
rm -f "$probe_src" "$probe_bin"
if [ "$probe_out" != "0" ]; then
    die "the setuid probe reported effective uid '${probe_out:-<nothing>}' instead of 0.
       Challenges 10 and 11 cannot work in this container."
fi
say "  setuid works"

# --------------------------------------------------------------------------
# 4. config + the perm command
# --------------------------------------------------------------------------
say "Writing $PERM_CONF"
cat > "$PERM_CONF" <<EOF
# Written by linux-shell-playground/setup.sh -- do not edit by hand.
REPO_ROOT=$REPO_ROOT
STUDENT=$STUDENT
LAB_ROOT=$LAB_ROOT
EOF
chmod 644 "$PERM_CONF"

# Challenge scripts are read live from the repo, so an instructor editing a
# check.sh sees the change on the next `perm check` with no re-install.
chmod +x "$REPO_ROOT/bin/perm"
ln -sfn "$REPO_ROOT/bin/perm" /usr/local/bin/perm

# The Codespaces image only grants the student passwordless sudo *as root*
# (`ALL=(root) NOPASSWD:ALL`), so `sudo -u nini ...` -- which every README
# asks for -- would prompt for a password. Allow run-as for the two lab
# people, validated with visudo before it is put in place.
say "Allowing passwordless 'sudo -u $MANAGER' and 'sudo -u $ENGINEER'"
SUDOERS_DROPIN=/etc/sudoers.d/perm-lab
printf '%s ALL=(%s,%s) NOPASSWD: ALL\n' "$STUDENT" "$MANAGER" "$ENGINEER" > "$SUDOERS_DROPIN.tmp"
chmod 440 "$SUDOERS_DROPIN.tmp"
if visudo -cf "$SUDOERS_DROPIN.tmp" >/dev/null 2>&1; then
    mv -f "$SUDOERS_DROPIN.tmp" "$SUDOERS_DROPIN"
else
    rm -f "$SUDOERS_DROPIN.tmp"
    warn "could not install $SUDOERS_DROPIN; 'sudo -u $MANAGER' may ask for a password"
fi

# --------------------------------------------------------------------------
# 5. the lab binaries
# --------------------------------------------------------------------------
say "Building the lab binaries"
mkdir -p "$LAB_ROOT/setuid/bin"
make -s -C "$REPO_ROOT/src" BINDIR="$LAB_ROOT/setuid/bin" all

# --------------------------------------------------------------------------
# 6. the challenges
# --------------------------------------------------------------------------
say "Setting up the twelve challenges"
for dir in "$REPO_ROOT"/challenges/*/; do
    [ -x "$dir/setup.sh" ] || chmod +x "$dir/setup.sh" 2>/dev/null || true
    CH_DIR="$dir" LAB_ROOT="$LAB_ROOT" STUDENT="$STUDENT" REPO_ROOT="$REPO_ROOT" \
        bash "$dir/setup.sh"
done

# Everything under /opt/lab must be traversable by nini and niko.
chmod 755 "$LAB_ROOT"
for d in "$LAB_ROOT"/ch*/; do
    [ -d "$d" ] && chown root:root "$d" && chmod 755 "$d"
done

# GNU chmod keeps setuid/setgid/sticky on directories through numeric modes, and
# on Codespaces /opt is setgid -- so every directory here inherits the setgid
# bit at creation, which silently pre-solves the setgid challenge. Strip all
# three special bits from every lab directory (no broken state uses them; the
# special-bit challenges are solved by the student at run time, not by setup).
find "$LAB_ROOT" -type d -exec chmod u-s,g-s,-t {} + 2>/dev/null || true

# --------------------------------------------------------------------------
# 7. greet the student in every new terminal
# --------------------------------------------------------------------------
student_home="$(getent passwd "$STUDENT" | cut -d: -f6)"
bashrc="$student_home/.bashrc"
touch "$bashrc"; chown "$STUDENT" "$bashrc"
if ! grep -qF "$BASHRC_MARK" "$bashrc"; then
    say "Adding the progress board to $bashrc"
    cat >> "$bashrc" <<'EOF'
# >>> linux-shell-playground >>>
# Show the challenge board in every new terminal. PERM_NO_GREETING is set by
# the challenge checks so they do not recurse back into this.
if [ -z "${PERM_NO_GREETING:-}" ] && command -v perm >/dev/null 2>&1; then
    perm list
fi
# <<< linux-shell-playground <<<
EOF
fi

printf '\n%sReady.%s  Open a new terminal, or run: %sperm%s\n\n' "$G" "$O" "$Y" "$O"
