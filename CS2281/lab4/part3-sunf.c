#include <signal.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/time.h>

char	ignore_errors	= 0;
char	verbose			= 0;
char	*argfile		= NULL;
long int timeout		= 3000;


char	error_seen		= 0;

char	**fa_argv;
int		fa_argc;
void print_argv(char **args)
{
	int i=0;
	while(args[i]) fprintf(stderr,"%s ",args[i++]);
	fprintf(stderr,"\n");
}

int child_pid;
int milliseconds;
int child_stat;
int th(int a)
{
	int wpid;
	do {
		//printf("%d\n",milliseconds);
		wpid = waitpid(child_pid, &child_stat,WNOHANG);
		if(wpid == 0)
		{
			if (milliseconds < timeout)
			{
				usleep(100);
				milliseconds++;
			}
			else
			{
				kill(child_pid,SIGKILL);
				printf("kill\n");
				return 1;
			}
		}
	} while (wpid==0 && milliseconds <= timeout);
	
	return -1;
}


int set_opts(int argc, char** argv)
{
	int c;
	while((c = getopt(argc,argv,"iva:")) != -1)
		switch(c)
		{
			case 'i': ignore_errors = 1;	break;
			case 'v': verbose = 1;			break;
			case 'a':
				argfile = optarg;
				break;
			case '?':
				if (optopt == 'a')
					fprintf(stderr,"Option -%c requires an argument.\n",optopt);
				else if(isprint(optopt))
					fprintf(stderr, "Unknown option '-%c'\n",optopt);
				else
					fprintf(stderr,
							"Unknown option character `\\x%x'.\n",
							optopt);
		}
	return optind;
}

void read_file(char *argfile)
{
	FILE *af = fopen(argfile,"r");
	char **args = (char **)malloc(sizeof(char**)*64);
	int argc = 0;
	char buf[128];
	while((fscanf(af,"%s",buf))!=EOF)
	{
		unsigned int size = strlen(buf);
		char *arg = (char *)malloc(size);
		strncpy(arg,buf,size);
		args[argc++] = arg;
	}
	args[argc] = NULL;	
	fa_argv = args;
	fa_argc = argc;
}



char **append_args(int argc, char** argv)
{
	char **new_args = (char **)malloc(sizeof(char **) * (argc + fa_argc + 1));
	//printf("%d %d %d\n",argc,fa_argc,argc+fa_argc);
	memcpy(new_args,		argv,	argc*sizeof(char **));
	memcpy(new_args + argc,	fa_argv,fa_argc*sizeof(char**));
	new_args[argc+fa_argc] = NULL;
	return new_args;
}


FILE *f;
int main(int argc,char** argv,char *envp[])
{
	int a;
	f = stdin;
	if((a = set_opts(argc,argv)) < argc) f = fopen(argv[a],"r");

	if(argfile != NULL) read_file(argfile);

	//printf("%d %d %s\n",ignore_errors,verbose,argfile);
	char input[128];
	while(fgets(input,sizeof(input),f)!=NULL)
	{
		unsigned int j = 0;
		input[strlen(input)-1] = '\0';
		if(input[0] !='#') 
		{
			char* toks[64];
			char* token;
			token = strtok(input," ");
			while(token !=NULL)
			{
				toks[j++] = token;
				token = strtok(NULL," ");
			}
			toks[j] = NULL;

			char **args;
			if(argfile != NULL) args = append_args(j,toks);
			else args = toks;

			if(verbose) print_argv(args);
			struct itimerval new;
			switch(child_pid = fork())
			{
				case -1:
					exit(1);
				case 0:
					child_stat = execvp(args[0],args);
					exit(child_stat);
				default:
					th(0);
					if(argfile != NULL) free(args);
			}

			int exitstat = WEXITSTATUS(child_stat);
			if (exitstat)
			{
				if(ignore_errors) error_seen = 1;
				else exit(1);
			}
		}
	}
	return 0;
}
