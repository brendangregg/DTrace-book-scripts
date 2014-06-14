#!/usr/sbin/dtrace -s
/*
 * chap2_pexec.d
 *
 * Example script from Chapter 2 of the book: DTrace: Dynamic Tracing in
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
	printf("%-20s %6s %6s %6s  %s\n", "ENDTIME",
	    "UID", "PPID", "PID", "PROCESS");
}

proc:::exec-success
{
	printf("%-20Y %6d %6d %6d  %s\n", walltimestamp,
	    uid, ppid, pid, execname);
}
