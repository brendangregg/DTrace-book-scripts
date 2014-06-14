#!/usr/sbin/dtrace -Zs
/*
 * j_thread.d
 *
 * Example script from Chapter 8 of the book: DTrace: Dynamic Tracing in
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
	printf("%-20s  %6s/%-5s -- %s\n", "TIME", "PID", "TID", "THREAD");
}

hotspot*:::thread-start
{
	this->thread = (char *)copyin(arg0, arg1 + 1);
	this->thread[arg1] = '\0';
	printf("%-20Y  %6d/%-5d => %s\n", walltimestamp, pid, tid,
	    stringof(this->thread));
}

hotspot*:::thread-stop
{
	this->thread = (char *)copyin(arg0, arg1 + 1);
	this->thread[arg1] = '\0';
	printf("%-20Y  %6d/%-5d <= %s\n", walltimestamp, pid, tid,
	    stringof(this->thread));
}
