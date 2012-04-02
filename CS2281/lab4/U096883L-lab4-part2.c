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
long int timeout		= 0;


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
long int milliseconds;
int child_stat;
int th(int a)
{
	struct timeval start_time;
	gettimeofday(&start_time,NULL);
	long int start = start_time.tv_sec*1000 + start_time.tv_usec/1000;
	int wpid;
	do {
		wpid = waitpid(child_pid, &child_stat,WNOHANG);
		if(wpid == 0)
		{
			if (milliseconds < timeout)
			{
				usleep(1);
				gettimeofday(&start_time,NULL);
				milliseconds = (start_time.tv_sec*1000 + start_time.tv_usec/1000) - start;
			}
			else
			{
				kill(child_pid,SIGKILL);
				//puts("killed");
				return -2;
			}
		}
		else 
		{
			return WEXITSTATUS(child_stat);
		}
	} while (1);
	
	return -1;
}


int set_opts(int argc, char** argv)
{
	int c;
	while((c = getopt(argc,argv,"iva:t:")) != -1)
		switch(c)
		{
			case 'i': ignore_errors = 1;	break;
			case 'v': verbose = 1;			break;
			case 'a':
				argfile = optarg;
				break;
			case 't':
				timeout = atoi(optarg);
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
	memcpy(new_args,        argv,    argc*sizeof(char **));
	memcpy(new_args + argc, fa_argv, fa_argc*sizeof(char**));
	new_args[argc+fa_argc] = NULL;
	return new_args;
}

void find_first_comment(char *command)
{
	int i=0;
	while( command[i] != '\n'
		&& command[i] !=  '#'
	) i++;
	command[i] = '\0';
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
		//input[strlen(input)-1] = '\0';
		find_first_comment(input);
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
		int exitstat;
		switch(child_pid = fork())
		{
			case -1:
				exit(1);
			case 0:
				child_stat = execvp(args[0],args);
				exit(child_stat);
			default:
				if (timeout)
				{
					exitstat = th(0);
					milliseconds = 0;
				}
				else
				{
					waitpid(child_pid, &child_stat,0);
					exitstat = WEXITSTATUS(child_stat);
				}
				if(argfile != NULL) free(args);
		}

		if (exitstat)
		{
			if(ignore_errors) error_seen = 1;
			else 
			{	
				if(exitstat == -2) exit(2);
				else exit(1);
			}
		}
	}
	return error_seen;
}
