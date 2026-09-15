# Builds the two lab binaries straight into /opt/lab/setuid/bin.
# Ownership and mode (including the absence of any setuid bit) are applied by
# setup.sh and by the challenge setups -- never here.

CC      ?= cc
CFLAGS  ?= -std=c99 -Wall -Wextra -Werror -O2
BINDIR  ?= /opt/lab/setuid/bin

PROGS   := checkpw catfile
TARGETS := $(addprefix $(BINDIR)/,$(PROGS))

.PHONY: all clean
all: $(TARGETS)

$(BINDIR):
	mkdir -p $(BINDIR)

$(BINDIR)/%: %.c | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $<
	chmod 0755 $@

clean:
	rm -f $(TARGETS)
