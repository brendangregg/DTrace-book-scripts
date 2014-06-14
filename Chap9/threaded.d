#!/usr/sbin/dtrace -s
/*
 * threaded.d
 *
 * Example script from Chapter 9 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

profile:::profile-101
/pid != 0/
{
	@sample[pid, execname] = lquantize(tid, 0, 128, 1);
}

profile:::tick-1sec
{
	printf("%Y,\n", walltimestamp);
	printa("\n @101hz   PID: %-8d CMD: %s\n%@d", @sample);
	printf("\n");
	trunc(@sample);
}
