#!/usr/sbin/dtrace -s
/*
 * nfsv4rwsnoop.d
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
	printf("%-16s %-18s %2s %-10s %6s %s\n", "TIME(us)",
	    "CLIENT", "OP", "OFFSET(KB)", "BYTES", "PATHNAME");
}

nfsv4:::op-read-start
{
	printf("%-16d %-18s %2s %-10d %6d %s\n", timestamp / 1000,
	    args[0]->ci_remote, "R", args[2]->offset / 1024,
	    args[2]->count, args[1]->noi_curpath);
}

nfsv4:::op-write-start
{
	printf("%-16d %-18s %2s %-10d %6d %s\n", timestamp / 1000,
	    args[0]->ci_remote, "W", args[2]->offset / 1024,
	    args[2]->data_len, args[1]->noi_curpath);
}
