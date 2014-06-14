#!/usr/sbin/dtrace -s
/*
 * icmpstat.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

mib::icmp_*:
{
	@icmp[probename] = sum(arg0);
}

profile:::tick-1sec
{
	printf("\n%Y:\n\n", walltimestamp);
	printf("  %32s %8s\n", "STATISTIC", "VALUE");
	printa("  %32s %@8d\n", @icmp);
	trunc(@icmp);
}
