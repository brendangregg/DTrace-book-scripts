#!/usr/sbin/dtrace -s
/*
 * wrun.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
inline int MAX = 10;

dtrace:::BEGIN
{
	start = timestamp;
	printf("Tracing for %d seconds...hit Ctrl-C to terminate sooner\n",
	    MAX);
}

sched:::on-cpu
/pid == $target/
{
	self->ts = timestamp;
}

sched:::off-cpu
/self->ts/
{
	@[cpu] = sum(timestamp - self->ts);
	self->ts = 0;
}

profile:::tick-1sec
/++x == MAX/
{
	exit(0);
}

dtrace:::END
{
	printf("\nCPU distribution over %d milliseconds:\n\n",
	    (timestamp - start) / 1000000);
	printf("CPU microseconds\n--- ------------\n");
	normalize(@, 1000);
	printa("%3d %@d\n", @);
}
