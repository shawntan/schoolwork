#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEFAULT_LINES (10)

#define INPUT_SIZE 65536
char buffer[INPUT_SIZE],c;
unsigned int buf_ptr=0,count=0,start,N;

void reverse_line(int); // prototype for your function

int main(int argc, char *argv[])
{
	// do NOT modify
	// no need to understand argv[] yet but it is an array
	// of strings for the words in the command line
	// argc counts the number of words in the command line
	int n = -1;
	if (argc == 3 && !strcmp(argv[1], "-n"))
		n = atoi(argv[2]);
	else if (argc == 1) n = DEFAULT_LINES;
	else {
		fprintf(stderr, "Usage: %s [-n lines]\n", argv[0]);
		exit(1); // command line error
	}
	if (n < 0) n = 0;
	reverse_line(n);
	exit(0); // no errors
}

void reverse_line(int n) 
{
	N = n?n:DEFAULT_LINES;
	start = buf_ptr;
	while ((c = getchar()) != EOF) {
		buffer[buf_ptr] = c;
		buf_ptr = (buf_ptr+1)%INPUT_SIZE;
		if(c =='\n')
		{
			start = buf_ptr;
			if(count < N) count++;
		} else buffer[buf_ptr] = '\n';
	}
	if(buffer[buf_ptr]=='\n') start = (buf_ptr + 1)%INPUT_SIZE;
	while(count--) {
		buf_ptr = (INPUT_SIZE + start-2)%INPUT_SIZE;
		while(buffer[buf_ptr]!='\n') buf_ptr = (INPUT_SIZE + buf_ptr - 1)%INPUT_SIZE;
		start = buf_ptr = (buf_ptr + 1)%INPUT_SIZE;
		while(buffer[buf_ptr]!='\n') 
		{
			putchar(buffer[buf_ptr]);
			buf_ptr = (buf_ptr+1)%INPUT_SIZE;
		}
		putchar('\n');
	}
}

