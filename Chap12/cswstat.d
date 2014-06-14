#!/usr/sbin/dtrace -s
/*
 * cswstat.d
 *
 * Example script from Chapter 12 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	/* print header */
	printf("%-20s  %8s %12s %12s\n", "TIME", "NUM", "CSWTIME(us)",
	    "AVGTIME(us)");
	times = 0;
	num = 0;
}

sched:::off-cpu
{
	/* csw start */
	num++;
	start[cpu] = timestamp;
}

sched:::on-cpu
/start[cpu]/
{
	/* csw end */
	times += timestamp - start[cpu];
	start[cpu] = 0;
}

profile:::tick-1sec
{
	/* print output */
	printf("%20Y  %8d %12d %12d\n", walltimestamp, num, times/1000,
	    num == 0 ? 0 : times/(1000 * num));
	times = 0;
	num = 0;
}
