#include <stdio.h>

// example of copying stdin to stdout
// note that getchar and putchar are macros
// try: gcc -E getchar.c

// /*
int main()
{
	int c; // note the type is int and not char

	while ((c = getchar()) != EOF) // exit when end of file (EOF)
		putchar(c); // output a byte

	return(0);
}
// */

/*
// version using: feof, getc, putc
int main()
{
	int c; // note the type is int and not char

	c = getc(stdin); // getchar = getc(stdin)
	while (!feof(stdin)) { // stdin not EOF
		putc(c, stdout); // putchar = putc(stdout)
		c = getc(stdin); 
	}

	return(0);
}
*/

/*
// version using: feof, fgetc, fputc
int main()
{
	int c; // note the type is int and not char

	c = fgetc(stdin); // getchar = getc(stdin)
	while (!feof(stdin)) { // stdin not EOF
		fputc(c, stdout); // putchar = putc(stdout)
		c = fgetc(stdin); 
	}

	return(0);
}
*/

