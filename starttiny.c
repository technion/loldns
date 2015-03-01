/* tinydns management app 
 * By Joshua Small
 * Used as a daemontools replacement
 */
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "daemons.h"

#define APP "/usr/local/bin/tinydns"
#define LOGAPP "/usr/local/bin/loglol"

int main()
{
	char *dir;

        dir = getenv("DIR");

        if(!dir)
        {
                fprintf(stderr, "$DIR has not been defined\n");
                exit(0);
        }

        if(chdir(dir) != 0)
        {
                perror("failed to switch to start directory");
                exit(0);
        }

	setenvironment();
	gobackground();
	runapp(APP, LOGAPP, NULL);

	return 0;
}
