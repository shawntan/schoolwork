#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#define DEFAULT_LINES (10)
#define CHUNK_SIZE 16
void reverse_line(int); // prototype for your function
void startprog(void);
void endprog(void);

int main(int argc, char *argv[])
{
	// do NOT modify
	int n = -1;
	if (argc == 3 && !strcmp(argv[1], "-n"))
		n = atoi(argv[2]);
	else if (argc == 1) n = DEFAULT_LINES;
	else {
		fprintf(stderr, "Usage: %s [-n lines]\n", argv[0]);
		exit(1); // command line error
	}
	if (n < 0) n = 0;
	startprog();
	reverse_line(n);
	endprog();
	exit(0); // no errors
}

struct buf_chunk {
	char buf[CHUNK_SIZE];
	struct buf_chunk *next;
};
typedef struct buf_chunk buffer_c;

buffer_c *curr_buffer;
unsigned char offset;

buffer_c* new_buffer()
{
	buffer_c *tmp = (buffer_c *)malloc(sizeof(buffer_c));
	tmp->next = NULL;
	return tmp;
}
void trunc_bufchain(buffer_c *last)
{
	buffer_c *curr;
	buffer_c *tmp;
	curr = last->next;
	last->next = NULL;
	while(curr!=NULL) {
		tmp = curr->next;
		free(curr);
		curr = tmp;
	}
}
void set_new_head(buffer_c *head)
{
	if(curr_buffer) trunc_bufchain(curr_buffer);
	curr_buffer = head;
	offset = 0;
}
void read_char(char c)
{
	curr_buffer->buf[offset++] = c;
	if (offset==CHUNK_SIZE)
	{
		if(curr_buffer->next == NULL) curr_buffer->next = new_buffer();
		curr_buffer = curr_buffer->next;
		offset=0;
	}
	curr_buffer->buf[offset] = '\0';
}
void put_buffer(buffer_c *head)
{
	buffer_c *cur;
	cur = head;
	int i;
	do {
		i=0;
		while(i < CHUNK_SIZE)
		{
			putchar(cur->buf[i++]);
			if(i < CHUNK_SIZE && cur->buf[i] == '\0') return;
		}
		cur = cur->next;
	} while(cur);
}



void reverse_line(int n)
{
	buffer_c **stack = (buffer_c **)malloc(sizeof(buffer_c*)*n);
	int i;
	for(i=0;i<n;i++) stack[i] = NULL;
	int ptr = 0,count=0;
	char c;
	stack[ptr] = new_buffer();
	set_new_head(stack[ptr]);
	while((c=getchar()) != EOF) {
		if(c == '\n')
		{
			ptr = (ptr + 1)%n;
			if(stack[ptr]==NULL) stack[ptr] = new_buffer();
			set_new_head(stack[ptr]);
			if(count < n) count++;
		}
		else read_char(c);
	}
	while(count--) {
		ptr = (n + ptr-1)%n;
		put_buffer(stack[ptr]);
		putchar('\n');
	}
	return;
}

