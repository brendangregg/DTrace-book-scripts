#!/usr/sbin/dtrace -s
/*
 * ipproto.d
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

ip:::send,
ip:::receive
{
	this->protostr = args[2]->ip_ver == 4 ?
	    args[4]->ipv4_protostr : args[5]->ipv6_nextstr;
	@num[args[2]->ip_saddr, args[2]->ip_daddr, this->protostr] = count();
}

dtrace:::END
{
	printf("   %-28s %-28s %6s %8s\n", "SADDR", "DADDR", "PROTO", "COUNT");
	printa("   %-28s %-28s %6s %@8d\n", @num);
}
