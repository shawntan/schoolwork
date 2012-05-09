#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *reconstruct_commandline(char *argv[])
{
	int i = 0;
	int total_size = 0;
	while(argv[i] != NULL) total_size += strlen(argv[i++]) + 1;

	char *buf = (char *)malloc(total_size);
	buf[0] = '\0';
	i = 0;
	while(argv[i] != NULL) 
	{
		strcat(buf,argv[i++]);
		strcat(buf," ");
	}
	return buf;
}

int main(int argc, char **argv)
{
	puts(reconstruct_commandline(argv));
	return 0;
}
