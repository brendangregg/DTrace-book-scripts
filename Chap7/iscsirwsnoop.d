#!/usr/sbin/dtrace -s
/*
 * iscsirwsnoop.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
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
	printf("%-16s %-18s %2s %-8s %6s\n", "TIME(us)", "CLIENT", "OP",
	    "BYTES", "LUN");
}

iscsi*:::data-send
{
	printf("%-16d %-18s %2s %-8d %6d\n", timestamp / 1000,
	    args[0]->ci_remote, "R", args[1]->ii_datalen, args[1]->ii_lun);
}

iscsi*:::data-receive
{
	printf("%-16d %-18s %2s %-8d %6d\n", timestamp / 1000,
	    args[0]->ci_remote, "W", args[1]->ii_datalen, args[1]->ii_lun);
}
