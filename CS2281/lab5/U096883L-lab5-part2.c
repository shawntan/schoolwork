#include <procfs.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <sys/types.h>
#include <dirent.h>
#include <pwd.h>
#include <string.h>
#define DEBUG 0

typedef struct t_proc {
	int pid;
	int ppid;
	char login_shell;
	int uid;
	time_t start;
	int desc;
	char progname[256];
} proc;

int pid = 0;
int unique_uids = 0;
int descendants = 0;
int *uuids;
proc **proc_structs;
int uuid_ptr;


proc *new_proc(int pid,char *progname,int ppid,int uid,time_t start, char login_shell)
{
	proc *p = (proc *) malloc(sizeof(proc));
	p->pid = pid;
	p->uid = uid;
	p->ppid = ppid;
	p->start = start;
	p->login_shell = login_shell;
	strcpy(p->progname,progname);
	return p;
}

void add_uid(int uid)
{
	uuids[uuid_ptr++]=uid;
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
	while((c = getopt(argc,argv,"pun")) != -1)
		switch(c)
		{
			case 'p': pid = 1;			break;
			case 'u': unique_uids = 1;	break;
			case 'n': descendants = 1;  break;
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
		if (( p == str 					|| *(p-1) == ':')
	 	&&  ( end >= str + strlen(str)  || *(end) == ':')
		)
			return 1;
		else return 0;
	}
	return 0;
}

char * shells_str;
int in_shells(char *progname){return find_tok(progname,shells_str);}

void print_procinfo(proc *p)
{
	int print = 1;
	if (p->login_shell)
	{
		if (unique_uids)
		{
			if(seen_uid(p->uid)) print = 0;
			else add_uid(p->uid);
		}
		if(print)
		{
			struct passwd *user_p = getpwuid(p->uid);
			time_t t = p->start;
		
			printf("%8s ",user_p->pw_name);
			if(unique_uids) printf("\n");
			else
			{
				if(pid)	printf("%5d ",p->pid);
				if(descendants) printf("%4d ",p->desc);
				printf("%16s %.24s\n",
						p->progname,
						ctime(&t)
				);
			}
		}
	}
}

int proc_count = 0;
void save_procinfo(char *filename,psinfo_t *psinf)
{
	if(DEBUG) printf("%s\n",filename);
	FILE *fd = fopen(filename,"r");
	if (fd > 0)
	{
		psinfo_t psinfo;
		fread(&psinfo,sizeof(psinfo_t),1,fd);
		proc *p = new_proc(
			psinfo.pr_pid,
			psinfo.pr_fname,
			psinfo.pr_ppid,
			psinfo.pr_uid,
			psinfo.pr_start.tv_sec,
			psinfo.pr_psargs[0] == '-' && in_shells(psinfo.pr_fname)
		);
		proc_structs[proc_count++] = p;
		proc_structs[proc_count] = NULL;
		fclose(fd);
	}
}


char *def_shells = "bash:sh";
void get_shells()
{
	shells_str = getenv("MYSHELLS");
	if(shells_str == NULL) shells_str = def_shells;
}

proc *find_proc(int pid)
{
	int i = 0;proc *p;
	while((p = proc_structs[i++]))
		if(p->pid == pid) return p;
	return NULL;
}

void increment_ancestors(proc *p)
{
	p->desc++;
	if(p->ppid && (p->pid != p->ppid))
		increment_ancestors(find_proc(p->ppid));
	else return;
}
void compute_descendants()
{
	int i = 0;proc *p;
	while((p = proc_structs[i++])) increment_ancestors(p);
}

int main(int argc, char **argv)
{
	get_shells();
	setflags(argc,argv);
	proc *ps[10000];
	proc_structs = ps;
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
			if(descendants) printf("%4s ","N");
			printf("%16s %.24s\n","FNAME","STIME");
		}

		while ((ep = readdir(dp)))
		{
			if(ep->d_name[0] >= '0' && ep->d_name[0] <= '9')
			{
				sprintf(buf,"/proc/%s/psinfo",ep->d_name);
				save_procinfo(buf,&psinfo_buf);
				//print_procinfo(buf,&psinfo_buf);
			}
		}

		(void)closedir(dp);
	}
	else perror ("Couldn't open the directory");	
	compute_descendants();
	proc *p;int i = 0;
	while ((p = proc_structs[i++])) print_procinfo(p);

	return 0;
}
