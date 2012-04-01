#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <stdlib.h>
int i;
void timer_handler (int signum)
{
	static int count = 0;
	printf ("timer expired %d times\n", ++count);
	kill(i,9);
}
void killer()
{
	puts("fork");

	exit(0);
}
int main ()
{
	/* Start a virtual timer. It counts down whenever this process is
	   executing. */
	while(1)
	{
		int somestuff=0;
		if((i=fork()) > 0)
		{
			struct sigaction sa;
			struct itimerval timer;
			/* Install timer_handler as the signal handler for SIGVTALRM. */
			memset (&sa, 0, sizeof (sa));
			sa.sa_handler = &timer_handler;
			sigaction (SIGVTALRM, &sa, NULL);

			/* Configure the timer to expire after 250 msec... */
			timer.it_value.tv_sec = 0;
			timer.it_value.tv_usec = 2500000;
			/* ... and every 250 msec after that. */
			timer.it_interval.tv_sec = 0;
			timer.it_interval.tv_usec = 250000000;
			setitimer (ITIMER_VIRTUAL, &timer, NULL);
			printf("waiting\n");
			wait(&somestuff);
		} else
		{
			char *p[] = {"sleep","5",NULL};
			execvp(p[0],p);
		}
	}
	return 0;
	/* Do busy work. */
}
