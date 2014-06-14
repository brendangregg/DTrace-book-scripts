#!/usr/sbin/dtrace -s
/*
 * tcpbytes.d
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
	printf("Tracing TCP payload bytes... Hit Ctrl-C to end.\n");
}

tcp:::receive
{
	@bytes[args[2]->ip_saddr, args[4]->tcp_dport] =
	    sum(args[2]->ip_plength - args[4]->tcp_offset);
}

tcp:::send
{
	@bytes[args[2]->ip_daddr, args[4]->tcp_sport] =
	    sum(args[2]->ip_plength - args[4]->tcp_offset);
}

dtrace:::END
{
	printf("  %-32s %-6s %16s\n", "REMOTE", "LPORT", "BYTES");
	printa("  %-32s %-6d %@16d\n", @bytes);
}
