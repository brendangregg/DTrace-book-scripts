#!/usr/sbin/dtrace -s
/*
 * nfsv4ops.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	trace("Tracing NFSv4 operations... Interval 5 secs.\n");
}

nfsv4:::op-*-start
{
	@ops[args[0]->ci_remote, probename] = count();
}

profile:::tick-5sec,
dtrace:::END
{
	printf("\n   %-32s %-28s %8s\n", "Client", "Operation", "Count");
	printa("   %-32s %-28s %@8d\n", @ops);
	trunc(@ops);
}
