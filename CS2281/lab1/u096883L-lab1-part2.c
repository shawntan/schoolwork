
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char ** argv) {
	int count;
	scanf("%d",&count);
	printf("#include <stdio.h>\n");	
	printf("int main() {\n");
	printf("\tint ");
	int i;
	for(i=0;i<count;i++) printf(" %c%s",97+i, i<count-1?",":";\n");

	printf("\tscanf( \"");
	for(i=0;i<count;i++) printf("%%d%s", i<count-1?" ":"");	
	printf("\", ");
	for(i=0;i<count;i++) printf("&%c%s", 97+i ,i<count-1?", ":"");	
	printf(" );\n");

	for(i=0;i<count;i++) {
		printf("\tif( ");
		int j;
		for(j=0;j<count;j++) {
			if(j != i) {
				printf("%c > %c %s", 97+i, 97+j
						,j==count-1 ||
						 (j==count-2 && j+1 == i)?"":"&& ");
			}
		}
		printf(") printf( \"%%d\\n\", %c );\n",97+i);
	}
	printf("\treturn 0;\n}");
	return 0;
}
