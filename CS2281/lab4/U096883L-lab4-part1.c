#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
/*
char **tokenize(unsigned int c, char *input)
{
	unsigned int i=0;
	unsigned int tok_cnt = 1;
	for(i=0;i<c;i++)
	{
		if(input[i]==' ')
		{
			input[i] = '\0';
			tok_cnt++;
		}
	}
	input[c] = '\0';
	for(i=1;i<c;i++) 

}*/
int main(int argc,char** argv,char *envp[])
{
	FILE *f;
	if(argc > 1) f = fopen(argv[1],"r");
	else f = stdin;
	char input[128];
	int stat = 0;
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
			int pid;
			switch(pid = fork())
			{
				case -1:
					exit(1);
				case 0:
					stat = execve(toks[0],toks,NULL);
					exit(stat);
				default:
					waitpid(pid,&stat,0);
			}
			int exitstat = WEXITSTATUS(stat);
			if (exitstat)
			{
				if(exitstat == 255) exit(1);
				else exit(exitstat);
			}
		}
	}
	return 0;
}
