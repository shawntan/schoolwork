#include <stdio.h>
int main()
{
	int pid = fork(), status;
	char *args[6] = {"echo","test","fork","&","execvp",0};
	if (pid==0) {execvp(args[0],args); printf("child stop\n"); }
	else { wait(&status); printf("parent stop\n");}
	return 0;
}
