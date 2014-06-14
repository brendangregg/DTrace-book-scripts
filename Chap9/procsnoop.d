#!/usr/sbin/dtrace -s
/*
 * procsnoop.d
 *
 * Example script from Chapter 9 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-8s %5s %6s %6s %s\n", "TIME(ms)", "UID", "PID", "PPID",
	    "COMMAND");
	start = timestamp;
}

proc:::exec-success
{
	printf("%-8d %5d %6d %6d %s\n", (timestamp - start) / 1000000,
	    uid, pid, ppid, curpsinfo->pr_psargs);
}
