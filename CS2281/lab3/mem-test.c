#include <stdio.h>
#include <stdlib.h>

void startprog();
void endprog();

int main(int argc, char *argv[])
{
	int size;
	char *p;

	startprog(); // record initial size of heap (dynamic memory)
	printf("malloc size in K? ");
	scanf("%d", &size);
	p = malloc(size*1024); // p not used
	endprog(); // prints final heap size
	return 0;
} 
