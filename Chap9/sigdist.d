#!/usr/sbin/dtrace -s
/*
 * sigdist.d
 *
 * Example script from Chapter 9 of the book: DTrace: Dynamic Tracing in
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

proc:::signal-send
{
	@Count[execname, stringof(args[1]->pr_fname), args[2]] = count();
}

dtrace:::END
{
	printf("%16s %16s %6s %6s\n", "SENDER", "RECIPIENT", "SIG", "COUNT");
	printa("%16s %16s %6d %6@d\n", @Count);
}
