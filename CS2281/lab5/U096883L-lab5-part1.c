#include <procfs.h>
#include <stdio.h>
#include <malloc.h>
#include <sys/types.h>
#include <dirent.h>
#include <pwd.h>
#define DEBUG 0

void print_procinfo(char *filename,psinfo_t *psinf)
{
	if(DEBUG) printf("%s\n",filename);
	FILE *fd = fopen(filename,"r");
	if (fd > 0)
	{
		psinfo_t psinfo;
		fread(&psinfo,sizeof(psinfo_t),1,fd);
		struct passwd *user_p = getpwuid(psinfo.pr_uid);
		time_t t = (time_t)psinfo.pr_start.tv_sec;

		printf("%8s %5d %16s %0.24s\n",
				user_p->pw_name,
				psinfo.pr_pid,
				psinfo.pr_fname,
				ctime(&t)
		);
		fclose(fd);
	}
}

int main()
{
	DIR *dp;
	struct dirent *ep;
	psinfo_t psinfo_buf;
	dp = opendir ("/proc");
	char buf[128];
	if (dp != NULL)
	{
		printf("%8s %5s %16s %0.24s\n","UID","PID","FNAME","STIME");
		while (ep = readdir (dp))
		{
			if(ep->d_name[0] >= '0' && ep->d_name[0] <= '9')
			{
				sprintf(buf,"/proc/%s/psinfo",ep->d_name);
				print_procinfo(buf,&psinfo_buf);
			}

		}

		(void) closedir (dp);
	}
	else
		perror ("Couldn't open the directory");

	return 0;
}
