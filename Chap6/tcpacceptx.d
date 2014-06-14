#!/usr/sbin/dtrace -s
/*
 * tcpacceptx.d
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
	printf("Tracing... Hit Ctrl-C to end.\n");
}

tcp:::accept-established
{
	@num[args[2]->ip_saddr, args[4]->tcp_dport] = count();
}

dtrace:::END
{
	printf("   %-26s %-8s %8s\n", "HOSTNAME", "PORT", "COUNT");
	printa("   %-26I %-8P %@8d\n", @num);
}
