#!/usr/sbin/dtrace -s
/*
 * xdrshow.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing XDR calls... Hit Ctrl-C to end.\n");
}

fbt::xdr_*:entry
{
	@num[execname, func(caller), probefunc] = count();
}

dtrace:::END
{
	printf(" %-12s %-28s %-25s %9s\n", "PROCESS", "CALLER", "XDR_FUNCTION",
	    "COUNT");
	printa(" %-12.12s %-28a %-25s %@9d\n", @num);
}
