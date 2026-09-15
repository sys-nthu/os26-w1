/* catfile.c -- deliberately naive "print any file" helper.
 *
 * The caller chooses the path. That single design decision is the whole point
 * of challenge 11: once this is setuid root it will print anything on the
 * machine. Compare with checkpw.c, which picks its own file.
 *
 * The /proc guard is here only so the lab cannot be used to rummage through
 * other people's process memory in a shared classroom container.
 */
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    FILE *f;
    char buf[4096];
    size_t n;

    if (argc != 2) {
        fprintf(stderr, "usage: catfile <path>\n");
        return 1;
    }

    if (strncmp(argv[1], "/proc", 5) == 0) {
        fprintf(stderr, "catfile: paths under /proc are not allowed\n");
        return 1;
    }

    f = fopen(argv[1], "r");
    if (f == NULL) {
        fprintf(stderr, "catfile: cannot open %s\n", argv[1]);
        return 1;
    }

    while ((n = fread(buf, 1, sizeof buf, f)) > 0) {
        if (fwrite(buf, 1, n, stdout) != n) {
            fclose(f);
            return 1;
        }
    }
    fclose(f);
    return 0;
}
