#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "daemons.h"

#define APP "/usr/local/bin/dnscache"
#define LOGAPP "/usr/local/bin/loglol"
#define SEED "../seed"

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
	runapp(APP, LOGAPP, SEED);

	return 0;
}
