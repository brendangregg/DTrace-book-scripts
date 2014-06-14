#!/usr/sbin/dtrace -s
/*
 * zioprint.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
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
	printf("%-16s %-3s %-22s %-6s %s\n", "TIME(us)", "CPU", "FUNC",
	    "NAME", "ARGS");
}

fbt::zio_*:entry
{
	printf("%-16d %-3d %-22s %-6s %x %x %x %x %x\n", timestamp / 1000,
	    cpu, probefunc, probename, arg0, arg1, arg2, arg3, arg4);
}

fbt::zio_*:return
{
	printf("%-16d %-3d %-22s %-6s %x %x\n", timestamp / 1000, cpu,
	    probefunc, probename, arg0, arg1);
}
