#!/usr/sbin/dtrace -s
/*
 * iscsiwho.d
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
	printf("Tracing iSCSI... Hit Ctrl-C to end.\n");
}

iscsi*:::
{
	@events[args[0]->ci_remote, probename] = count();
}

dtrace:::END
{
	printf("   %-26s %14s %8s\n", "REMOTE IP", "iSCSI EVENT", "COUNT");
	printa("   %-26s %14s %@8d\n", @events);
}
