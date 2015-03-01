#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <limits.h>
#include <dirent.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <signal.h>
#include <ctype.h>

#define LOGDIR "./log"
#define LINESIZE 256
#define LOGLINES 128000
#define CURFILENAME "current"
#define KEEPTIME (60*60*24*2) 


static void dropprivs(void);
static FILE *newlogfile(FILE *oldstream);
static void oldcleanup(void);

volatile sig_atomic_t flush_time = 0;


/* The signal handler just clears the flag and re-enables itself. */
static void catch_alarm (int sig)
{
	flush_time = 1;
	signal (sig, catch_alarm);
}

int main()
{
	FILE *logfile = NULL;
	char readline[LINESIZE];
	int lines = 0;


	dropprivs();
	logfile = newlogfile(NULL);

	oldcleanup();

	signal (SIGALRM, catch_alarm);
	alarm(180);

	while(1)
	{
		if(fgets(readline, LINESIZE, stdin)==NULL)
		{
			fprintf(logfile, "%s\n", "Daemon shutdown");
			exit(0);
		}
		if(flush_time)
		{
			fflush(logfile);
			alarm(180);
		}
		if(fprintf(logfile,"%s", readline)<1)
		{
			perror("Failed to write logfile");
			exit(0);
		}
		if (lines++ > LOGLINES)
		{
			logfile = newlogfile(logfile);
			oldcleanup();
			lines = 0;
		}
	}

	return 0;


}

static void dropprivs(void)
{
	char *uid_s, *gid_s;
	int uid_i, gid_i;

	if(chroot(LOGDIR)!=0)
	{
		perror("Chroot failed");
		exit(0);
	}
	if(chdir("/")!=0)
	{
		perror("Chdir failed");
		exit(0);
	}

	uid_s = getenv("LOGUID");
	gid_s = getenv("GID");
	if (!gid_s || !uid_s)
	{
		fprintf(stderr,"$UID or $GID not set, failed\n");
		exit(0);
	}

	if(sscanf(uid_s,"%d",&uid_i)!=1)
	{
		fprintf(stderr,"$UID failure\n");
		exit(0);
	}

	if(sscanf(gid_s,"%d",&gid_i)!=1)
	{
		fprintf(stderr,"$GID failure\n");
		exit(0);
	}

	if(uid_i==0)
	{
		fprintf(stderr,"This program does not run as root, set $UID\n");
		exit(0);
	}

	if(setgid(gid_i)!=0 || setuid(uid_i)!=0 )
	{
		perror("Drop privs failed");
		exit(0);
	}

}

static FILE *newlogfile(FILE *oldstream)
{
	/* Creates a new log file. Renames the old one based on time() */
	FILE *logfile;
	time_t thetime;
	char oldfilename[NAME_MAX+1];
	struct stat buf;

	thetime = time(NULL);

	snprintf(oldfilename, NAME_MAX, "%lu",(unsigned long)thetime);

	if(oldstream == NULL)
	{
		/* In this case, an existing log means something is broken */
		if (stat(oldfilename, &buf)==0)
		{
			fprintf(stderr, "Log file exists already!\n");
			exit(0);
		}
	} 
	else
	{
		/* In this case, an existing file means we are 
		 *  rotating too fast */
		if (stat(oldfilename, &buf)==0)
		{
			fprintf(oldstream, "ROTATING TOO FAST\n");
			return oldstream;
		}
	}

	if (stat(CURFILENAME, &buf) == 0)
	{
		if(oldstream)
		{
			fflush(oldstream);
			fclose(oldstream);
		}
		if(rename(CURFILENAME, oldfilename)!=0)
		{
			perror("Unable to rename log");
			exit(0);
		}
	}


	logfile = fopen(CURFILENAME, "w");
	if(!logfile)
	{
		perror("Couldn't open logfile");
		exit(0);
	}

	return logfile;
}

static void oldcleanup()
{
	DIR *logdir;
	struct dirent *entry;
	char *filename;
	struct stat filestats;
	struct stat filestats2;
	int fd;

        logdir = opendir("..");

        if(!logdir)
        {
                perror("Couldn't read directory");
                exit(0);
        }

        while((entry = readdir(logdir)) !=NULL)
        {
		/* We deliberately handle errors here by just moving on. */
		/* Check we have a regular file we own before deletion */
                filename = entry->d_name;

		if(!isdigit(filename[0]))
		{
			continue;
		}
		if(stat(filename, &filestats)==-1)
		{
			continue;
		}
		if(!S_ISREG(filestats.st_mode))
		{
			continue;
		}
		if(filestats.st_uid != atoi(getenv("LOGUID")))
		{
			continue;
		}
		if((time(NULL) - filestats.st_mtime) > KEEPTIME)
		{
			/* Time to decide this file dies.
			 * Epic race handling here
			 */
			if((fd = open(filename, O_RDONLY)) < 0)
			{
				continue;
			}
			if(fstat(fd, &filestats2)==-1)
			{
				continue;
			}
			if(filestats.st_dev != filestats2.st_dev ||
				filestats.st_ino != filestats2.st_ino)
			{
				continue;
			}

			unlink(filename);
			close(fd);
		}
	}

	closedir(logdir);
}


  
