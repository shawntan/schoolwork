#include <stdio.h>
#define INPUT_SIZE 65536
#define N 10
/*
 * Shawn Tan
 * shawn.tan@nus.edu.sg
 * U096883L
 */
char buffer[INPUT_SIZE],c;
unsigned int buf_ptr=0,count=0,start;
unsigned int move_counter;
int main(){
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
	unsigned int stop_point = start;
	while(count--)
	{
		buf_ptr = (INPUT_SIZE + start-2)%INPUT_SIZE;
		while(buffer[buf_ptr]!='\n')
			buf_ptr = (INPUT_SIZE + buf_ptr - 1)%INPUT_SIZE;
		start = buf_ptr = (buf_ptr + 1)%INPUT_SIZE;
		while(buffer[buf_ptr]!='\n') 
		{
			putchar(buffer[buf_ptr]);
			buf_ptr = (buf_ptr+1)%INPUT_SIZE;
		}
		putchar('\n');
		if (start == stop_point) break;
	}
	return 0;
}
