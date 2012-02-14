#include <stdio.h>
void reverse_on_s(char* str,int start,int end,int inc) {
	if (end==start) return;
    int i=start;
    while(str[i] != 's' && i != end) {
        printf("%c",str[i]);
        i += inc;
    }
    reverse_on_s(str,end,i+inc,-1*inc);
}

main() {
    reverse_on_s("Hello shitheads and moron",0,26,1);
}
