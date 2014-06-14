#!/usr/sbin/dtrace -s
/*
 * ipio.d
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
	printf(" %3s %10s %15s    %15s %8s %6s\n", "CPU", "DELTA(us)",
	    "SOURCE", "DEST", "INT", "BYTES");
	last = timestamp;
}

ip:::send
{
	this->delta = (timestamp - last) / 1000;
	printf(" %3d %10d %15s -> %15s %8s %6d\n", cpu, this->delta,
	    args[2]->ip_saddr, args[2]->ip_daddr, args[3]->if_name,
	    args[2]->ip_plength);
	last = timestamp;
}

ip:::receive
{
	this->delta = (timestamp - last) / 1000;
	printf(" %3d %10d %15s <- %15s %8s %6d\n", cpu, this->delta,
	    args[2]->ip_daddr, args[2]->ip_saddr, args[3]->if_name,
	    args[2]->ip_plength);
	last = timestamp;
}
