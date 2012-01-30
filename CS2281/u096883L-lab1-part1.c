#include <stdio.h>
#include <stdlib.h>

int main(int argc, char ** argv) {
	int count;
	scanf("%d",&count);
	printf("#include <stdio.h>\n");	
	printf("int main() {\n");	
	int i;
	for(i=0;i<count;i++) {
		printf("\tprintf(\"");
		int j;
		for(j=0;j<count;j++) printf("*");
		printf("\\n\");\n");
	}
	printf("\treturn 0;\n");
	printf("return 0\n}");

	return 0;
}
