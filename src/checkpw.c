/* checkpw.c -- toy "authenticate a user" helper for the setuid lab.
 *
 * Reads a password store that the caller is not allowed to read, and answers a
 * yes/no question about it. It never echoes a line of the store. This is the
 * shape every real setuid helper has: it decides for itself which file it
 * touches, and it only ever hands back a verdict.
 *
 * Built by src/Makefile. The setuid bit is NOT set here -- that is the lab.
 */
#include <stdio.h>
#include <string.h>

#define PASSWORD_STORE "/opt/lab/setuid/vault/passwords.txt"

int main(int argc, char **argv)
{
    FILE *store;
    char line[256];
    int granted = 0;

    if (argc != 3) {
        fprintf(stderr, "usage: checkpw <user> <password>\n");
        return 2;
    }

    store = fopen(PASSWORD_STORE, "r");
    if (store == NULL) {
        fprintf(stderr, "checkpw: cannot open password store\n");
        return 2;
    }

    while (fgets(line, sizeof line, store) != NULL) {
        char *sep;

        line[strcspn(line, "\r\n")] = '\0';
        sep = strchr(line, ':');
        if (sep == NULL)
            continue;
        *sep = '\0';

        if (strcmp(line, argv[1]) == 0 && strcmp(sep + 1, argv[2]) == 0) {
            granted = 1;
            break;
        }
    }
    fclose(store);

    puts(granted ? "ACCESS GRANTED" : "ACCESS DENIED");
    return granted ? 0 : 1;
}
