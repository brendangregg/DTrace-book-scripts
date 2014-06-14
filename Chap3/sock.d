#!/usr/sbin/dtrace -s
/*
 * sock.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

fbt:sockfs::entry
{
	@[execname, probefunc] = count();
}
END
{
	printf("%-16s %-24s %-8s\n", "EXEC", "SOCKFS FUNC", "COUNT");
	printa("%-16s %-24s %-@8d\n", @);
}
