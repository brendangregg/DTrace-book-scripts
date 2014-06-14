#!/usr/sbin/dtrace -s
/*
 * tcpnmap.d
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
	printf("Tracing for possible nmap scans... Hit Ctrl-C to end.\n");
}

tcp:::accept-refused
{
	@num["TCP_connect()_scan", args[2]->ip_daddr] = count();
}

tcp:::receive
/args[4]->tcp_flags == 0/
{
	@num["TCP_null_scan", args[2]->ip_saddr] = count();
}

tcp:::receive
/args[4]->tcp_flags == (TH_URG|TH_PUSH|TH_FIN)/
{
	@num["TCP_Xmas_scan", args[2]->ip_saddr] = count();
}

dtrace:::END
{
	printf("Possible scan events:\n\n");
	printf("   %-24s %-28s %8s\n", "TYPE", "HOST", "COUNT");
	printa("   %-24s %-28s %@8d\n", @num);
}
