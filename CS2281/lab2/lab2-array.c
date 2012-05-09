#include <stdio.h>

int Reset = 0;

int main()
{
	int i, a[4]; 

	for (i=0; i <= sizeof(a)/sizeof(int); i++)
		a[i] = Reset;
	printf("initialization finished\n");
	return(0);
}
