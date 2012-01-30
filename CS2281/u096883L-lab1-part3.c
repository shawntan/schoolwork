

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
	printf(");\n");
	
	printf("\tif( ");
	for(i=1;i<count;i++) {
		printf("a == %c %s",97+i,i==count-1?"":"&& ");
	}
	printf(") printf( \"NIL\\n\" );\n");
	for(i=0;i<count;i++) {
		int j;
		for(j=0;j<count;j++) {
			if(j != i) {
				printf("\tif( ");
				printf("%c < %c ",97+i,97+j);
				int k;
				for(k=0;k<count;k++) {
					if(k!=j && k != i) {
						printf(" && %c >= %c",97 + i,97 + k);
					}	
				}
				printf(" ) printf( \"%%d\\n\", %c );\n",97+i);
			}
		}
	}
	printf("\treturn 0;\n}\n");
	return 0;
}
