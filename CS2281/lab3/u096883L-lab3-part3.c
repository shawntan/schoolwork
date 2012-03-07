#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#define DEFAULT_LINES (10)
#define INIT_SIZE 32
#define GROW_FACTOR 2
void reverse_line(int); // prototype for your function
void startprog(void);
void endprog(void);

int roundoff(unsigned int len)
{
	len--;
	len |= len >> 1;
	len |= len >> 2;
	len |= len >> 4;
	len |= len >> 8;
	len |= len >> 16;
	len++;
	return len;
}

int main(int argc, char *argv[])
{
	// do NOT modify
	int n = -1;
	if (argc == 3 && !strcmp(argv[1], "-n"))
		n = atoi(argv[2]);
	else if (argc == 1) n = DEFAULT_LINES;
	else
	{
		fprintf(stderr, "Usage: %s [-n lines]\n", argv[0]);
		exit(1); // command line error
	}
	if (n < 0) n = 0;
	startprog();
	reverse_line(n);
	endprog();
	exit(0); // no errors
}

typedef struct
{
	char *buf;
	unsigned int len;
} buffer_c;

buffer_c* new_buffer()
{
	char *buf = (char *)malloc(INIT_SIZE);
	buffer_c *b = (buffer_c *)malloc(sizeof(buffer_c));
	printf("New Allocate %p\n",buf);
	b->buf = buf;
	b->len = INIT_SIZE;
	return b;
}
void increase_buffer(buffer_c* b)
{
	char *buf = (char *)malloc(GROW_FACTOR * (b->len));
	printf("Reallocate %p\n",buf);
	memcpy(buf,b->buf,b->len);
	free(b->buf);
	b->buf = buf;
	b->len = GROW_FACTOR*b->len;
}

buffer_c *curr_buf;
unsigned int curr_ptr=0; 
void truncate_buffer()
{
	unsigned int size = roundoff(curr_ptr+1);
	if(curr_buf->len <= size) return;
	printf("Truncating..");
	char *buf = (char *)malloc(size);
	printf("Allocate %p\n",buf);
	memcpy(buf,curr_buf->buf,curr_ptr+1);
	printf("Freeing %p\n",curr_buf->buf);
	free(curr_buf->buf);
	printf("Freed\n");
	curr_buf->buf = buf;
	curr_buf->len = size;
	printf("%d\n",curr_ptr+1);
	printf("%d\n",size);
}
void put_buffer(buffer_c* b)
{
	printf("%s",b->buf);
}
void read_char(char c)
{
	curr_buf->buf[curr_ptr++] = c;
	if(curr_ptr >= curr_buf->len) increase_buffer(curr_buf);
	curr_buf->buf[curr_ptr] = '\0';
	//printf("%s\n",curr_buf->buf);
}
void set_new_head(buffer_c *b)
{
	curr_buf = b;
	curr_ptr = 0;
}

void reverse_line(int n)
{
	buffer_c *stack[n];
	int i;
	for(i=0;i<n;i++) stack[i] = NULL; //fillall with null
	int ptr = 0,count=0;
	char c;
	stack[ptr] = new_buffer();
	set_new_head(stack[ptr]);
	while((c=getchar()) != EOF)
	{
		if(c == '\n')
		{
			truncate_buffer();
			ptr = (ptr + 1)%n;
			if(stack[ptr]==NULL) stack[ptr] = new_buffer();
			set_new_head(stack[ptr]);
			if(count < n) count++;
		}
		else read_char(c);
	}
	while(count--)
	{
		ptr = (n + ptr-1)%n;
		put_buffer(stack[ptr]);
		putchar('\n');
	}
	return;
}
