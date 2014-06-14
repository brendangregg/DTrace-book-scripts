#!/usr/sbin/dtrace -s
/*
 * tcpstate.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10

dtrace:::BEGIN
{
	printf(" %3s %12s  %-20s    %-20s\n", "CPU", "DELTA(us)", "OLD", "NEW");
	last = timestamp;
}

tcp:::state-change
{
	this->elapsed = (timestamp - last) / 1000;
	printf(" %3d %12d  %-20s -> %-20s\n", cpu, this->elapsed,
	    tcp_state_string[args[5]->tcps_state],
	    tcp_state_string[args[3]->tcps_state]);
	last = timestamp;
}
