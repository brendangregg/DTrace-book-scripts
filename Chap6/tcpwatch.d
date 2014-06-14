#!/usr/sbin/dtrace -s
/*
 * tcpwatch.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
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
	printf("%-20s  %-24s %-24s %6s\n", "TIME", "REMOTE", "LOCAL", "LPORT");
}

tcp:::accept-established
{
	printf("%-20Y  %-24s %-24s %6d\n", walltimestamp,
	    args[2]->ip_saddr, args[2]->ip_daddr, args[4]->tcp_dport);
}
