#!/usr/sbin/dtrace -s
/*
 * udpio.d
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
	printf("%-3s  %15s:%-5s      %15s:%-5s  %6s\n", "CPU",
	    "LADDR", "PORT", "RADDR", "PORT", "IPLEN");
}

udp:::send
{
	printf("%-3d  %15s:%-5d  ->  %15s:%-5d  %6d\n", cpu,
	    args[2]->ip_saddr, args[4]->udp_sport,
	    args[2]->ip_daddr, args[4]->udp_dport, args[2]->ip_plength);
}

udp:::receive
{
	printf("%-3d  %15s:%-5d  <-  %15s:%-5d  %6d\n", cpu,
	    args[2]->ip_daddr, args[4]->udp_dport,
	    args[2]->ip_saddr, args[4]->udp_sport, args[2]->ip_plength);
}
