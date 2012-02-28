#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEFAULT_LINES (10)

void reverse_line(int); // prototype for your function
void startprog(void);
void endprog(void);

int main(int argc, char *argv[])
{
	// do NOT modify
	int n = -1;
	if (argc == 3 && !strcmp(argv[1], "-n"))
		n = atoi(argv[2]);
	else if (argc == 1) n = DEFAULT_LINES;
	else {
		fprintf(stderr, "Usage: %s [-n lines]\n", argv[0]);
		exit(1); // command line error
	}
	if (n < 0) n = 0;
	startprog();
	reverse_line(n);
	endprog();
	exit(0); // no errors
}

void reverse_line(int n) 
{
	// your code
	// you may define other functions called from here
}

