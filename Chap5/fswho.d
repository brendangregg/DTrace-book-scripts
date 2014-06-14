#!/usr/sbin/dtrace -s
/*
 * fswho.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

fsinfo:::read,
fsinfo:::write
{
	@[execname, probename == "read" ? "R" : "W", args[0]->fi_fs,
	    args[0]->fi_mount] = sum(arg1);
}

dtrace:::END
{
	normalize(@, 1024);
	printf("  %-16s  %1s %12s  %-10s %s\n", "PROCESSES", "D", "KBYTES",
	    "FS", "MOUNTPOINT");
	printa("  %-16s  %1.1s %@12d  %-10s %s\n", @);
}
