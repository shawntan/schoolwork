#include <stdio.h>
#include <stdlib.h>

int N = 10;
int printmax(char* fun, char i) {
	if (i == 0) printf("%c",97+i);
	else {
		printf("%s(",fun);
		printmax(fun,i-1);
		printf(",%c)",97+i);
	}
}

int main(int argc, char ** argv) {
	char count;
	scanf("%d",&count);
	printf("#include <stdio.h>\n");	
	printf("Z(a,b) { return a>=b?a:b;}\n");
	printf("Y(a,b) { return a<=b?a:b;}\n");
	printf("int N,n,S,A=(1<<31);\n");
	printf("int W(int a,int b) {return Z(a,b)==N?(a==b?A:Y(a,b)):Z(a,b);}\n");
	printf("main() {\n");

	printf("\tint ");
	int i;
	for(i=0;i<count;i++) printf(" %c%s",97+i, i<count-1?",":";\n");

	printf("\tscanf( \"");
	for(i=0;i<count;i++) printf("%%d%s", i<count-1?" ":"");	
	printf("\", ");
	for(i=0;i<count;i++) printf("&%c%s", 97+i ,i<count-1?", ":"");	
	printf(");\n");


	printf("\tN = ");
	printmax("Z",count-1);
	printf(";\n");
	printf("\tn = ");	
	printmax("Y",count-1);
	printf(";\n");
	printf("\tS = ");
	printmax("W",count-1);
	printf(";\n");
	printf("\tS==A?printf(\"NIL\\n\"):printf(\"%%d\\n\",S);\n");
	printf("\tprintf(\"%%u\\n\",N-n);\n");
	printf("}\n");

	return 0;
}
