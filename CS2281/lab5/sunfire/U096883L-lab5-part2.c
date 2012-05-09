#include <procfs.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <sys/types.h>
#include <dirent.h>
#include <pwd.h>
#include <string.h>
#define DEBUG 0

int pid = 0;
int unique_uids = 0;
int *uuids;
int uuid_ptr;

void add_uid(int uid)
{
	uuids[uuid_ptr]=uid;uuid_ptr++;
}

int seen_uid(int uid)
{
	int i;
	for(i=0;i<uuid_ptr;i++)
	{
		if(uuids[i]==uid) return 1;
	}
	return 0;
}

void setflags(int argc, char **argv)
{
	char c;
	while((c = getopt(argc,argv,"pu")) != -1)
		switch(c)
		{
			case 'p': pid = 1;			break;
			case 'u': unique_uids = 1;	break;
		}
	if(DEBUG) printf("pid=%d unique_uids=%d\n",pid,unique_uids);
}

int find_tok(char *subs,char *str)
{
	char *p;
	if((p=strstr(str,subs)) != NULL)
	{
		char *end = p+strlen(subs);
		if (DEBUG) printf("%p %p \n",end,str + strlen(str));
		if( ( p == str 					|| *(p-1) == ':')
	 	&&  ( end >= str + strlen(str)  || *(end) == ':')
		)
			return 1;
		else return 0;
	}
	return 0;
}

char * shells_str;
int in_shells(char *progname){return find_tok(progname,shells_str);}

void print_procinfo(char *filename,psinfo_t *psinf)
{
	if(DEBUG) printf("%s\n",filename);
	FILE *fd = fopen(filename,"r");
	if (fd > 0)
	{
		psinfo_t psinfo;
		fread(&psinfo,sizeof(psinfo_t),1,fd);
		int print = 1;
		if (in_shells(psinfo.pr_fname) && psinfo.pr_psargs[0] == '-')
		{
			if (unique_uids)
			{
				if(seen_uid(psinfo.pr_uid)) print = 0;
				else add_uid(psinfo.pr_uid);
			}
			if(print)
			{
				struct passwd *user_p = getpwuid(psinfo.pr_uid);
				time_t t = (time_t)psinfo.pr_start.tv_sec;
			
				printf("%8s ",user_p->pw_name);
				if(unique_uids) printf("\n");
				else
				{
					if(pid)	printf("%5d ",(int) psinfo.pr_pid);
					printf("%16s %.24s\n",
							psinfo.pr_fname,
							ctime(&t)
					);
				}
			}
		}
		fclose(fd);
	}
}

char *def_shells = "bash:sh";
void get_shells()
{
	shells_str = getenv("MYSHELLS");
	if(shells_str == NULL) shells_str = def_shells;
}

int main(int argc, char **argv)
{
	get_shells();
	setflags(argc,argv);

	if (unique_uids)
	{
		int uidstr[10000];
		uuids = uidstr;
		int i = 10000;
		while(i--) uuids[i] = -1;
	}

	DIR *dp;
	struct dirent *ep;
	psinfo_t psinfo_buf;
	dp = opendir ("/proc");
	char buf[128];
	if (dp != NULL)
	{
		printf("%8s ","UID");
		if(unique_uids) printf("\n");
		else
		{
			if(pid) printf("%5s ","PID");
			printf("%16s %.24s\n","FNAME","STIME");
		}

		while ((ep = readdir(dp)))
		{
			if(ep->d_name[0] >= '0' && ep->d_name[0] <= '9')
			{
				sprintf(buf,"/proc/%s/psinfo",ep->d_name);
				print_procinfo(buf,&psinfo_buf);
			}
		}
		(void)closedir(dp);
	}
	else perror ("Couldn't open the directory");

	return 0;
}
