/* API for Daemon management
 * By Joshua Small
 */
#include <dirent.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/time.h>

#define ENVDIR "./env"
#define LOLSIZE 128
#define READPIPE fd[0]
#define WRITEPIPE fd[1]
#define LOGFILE "log/fatals"

static void stderrtofile();
static void redirect_fds();
static int readlimit(const char *filename);

void runapp(const char *app, const char *logapp, const char *infile)
{
	/* Simulates /service linkage. Runs *app with a pipe to *logapp */
	int fd[2];
	pid_t pid;

	if(pipe(fd)!=0)
	{
		perror("Pipe failed");
		exit(0);
	}
	
	/* Last appropriate place to close file descriptors. Would like to
	   wait until all the forking is done, but wanted parent processes
	   to have the closing done
        */
	redirect_fds();
	pid = fork();
	if (pid < 0)
	{
		perror("Fork failed");
		exit(0);
	}

	if(pid > 0)
	{
		close(STDIN_FILENO);
		if(infile && (open(infile, O_RDONLY) == -1))
		{
			perror("Could not open seed file");
			exit(0);
		}
		close(READPIPE); /* Close parent input */
		close(STDOUT_FILENO);
		dup2(WRITEPIPE, STDOUT_FILENO);
		close(STDERR_FILENO);
		dup2(WRITEPIPE, STDERR_FILENO); /* Most logging goes to stderr */
		execv(app, NULL); 
	}
	else
	{
		close(WRITEPIPE); /*Close child output */
		close(STDIN_FILENO);
		dup2(READPIPE, STDIN_FILENO);

		if(chdir(getenv("DIR")) == -1)
		{
			perror("Failed to change to $DIR");
			exit(0);
		}

		stderrtofile();

		execv(logapp, NULL);
		perror("Log exec failed");
		exit(0);
	}
}



void setenvironment()
{
	/* Cycles our ENVDIR, sets variables as FILENAME = contents(FILENAME)
	 * Simulates djb's envdir. Also replaces softlimit by acting on
	 * DATALIMIT and FDLIMIT variables
	 */
	DIR *envdir;
	struct dirent *entry;
	char value[LOLSIZE];
	char *filename;
	FILE *fi = NULL;
	struct rlimit limits;
	int limit;

	envdir = opendir(ENVDIR);

	if(!envdir ||(chdir(ENVDIR) == -1))
	{
		perror("Couldn't read environment");
		exit(0);
	}

	while((entry = readdir(envdir)) !=NULL)
	{
		filename = entry->d_name;
		if(filename[0] == '.')
		{
			continue;
		}
		fi = fopen(filename, "r");
		if (!fi)
		{
			perror("Cannot open env file");
			exit(0);
		}
		if(fgets(value, LOLSIZE, fi)!=NULL)
		{
			if(value[strlen(value)-1] == '\n')
				value[strlen(value)-1] = '\0';
			setenv(filename, value, 1);
			if(strcmp(filename,"DATALIMIT")==0)
			{
				limit = readlimit(value);
				limits.rlim_cur = limit;
				limits.rlim_max = limit;
				if(setrlimit(RLIMIT_DATA, &limits) != 0)
				{
					perror("Couldn't set limits");
					exit(0);
				}
			}
			if(strcmp(filename,"FDLIMIT")==0)
			{
				limit = readlimit(value);
				limits.rlim_cur = limit;
				limits.rlim_max = limit;
				if(setrlimit(RLIMIT_NOFILE, &limits) != 0)
				{
					perror("Couldn't set limits");
					exit(0);
				}
			}
		}
		fclose(fi);
		fi = NULL;

	}
	closedir(envdir);
}

static int readlimit(const char *value)
{
	int limit;

	limit =  strtol(value, (char **)NULL, 10);
	if (!limit)
	{
		perror("Failed to read limit");
		exit(0);
	}

	return limit;
}

void gobackground(void)
{
	/* So apparently the daemonize process is fork(), setsid(), fork() */
	pid_t pid;


	pid = fork();
	if(pid<0)
	{
		perror("Failed to go background");
		exit(0);
	}

	if(pid >0 )
	{
		/* Parent */
		exit(0);
	}

	/* Only child gets here */
	if(setsid() == -1)
	{
		perror("Failed to setsid");
		exit(0);
	}

	pid = fork();
	if(pid<0)
	{
		perror("Failed to go background");
		exit(0);
	}

	if(pid > 0)
	{
		/* Child */
		exit(0);
	}

}

static void redirect_fds()
{
	/* Note this doesn't deal with stderr. Must be done later */
	int fd;

	close(STDIN_FILENO);
	close(STDOUT_FILENO);

	if((fd = open ("/dev/null", O_RDWR))<0)
	{
		perror("Failed epically to open new fd");
		exit(0);
	}
	if(fd != STDIN_FILENO) /* It really should be */
	{
		dup2(fd,STDIN_FILENO);
	}
	dup2(STDIN_FILENO,STDOUT_FILENO);
}

static void stderrtofile()
{
        struct stat fdstats;

        /* stderr goes to fatals */

        if(lstat(LOGFILE, &fdstats) == -1)
        {
                perror("Epic failure");
                exit(0);
        }

        if(fdstats.st_uid != atoi(getenv("LOGUID")))
        {
                fprintf(stderr, "Fatals file incorrectly owned\n");
                exit(0);
	}

        if(S_ISLNK(fdstats.st_uid))
        {
                fprintf(stderr, "Fatals file cannot be a symlink\n");
                exit(0);
        }

	if(freopen(LOGFILE, "w+", stderr)==NULL)
	{
		perror("Failed to open fatals file");
		exit(0);
	}
}
