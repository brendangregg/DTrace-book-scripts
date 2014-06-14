#!/usr/sbin/dtrace -Zs
/*
 * tcl_procflow.d
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

self int depth;

dtrace:::BEGIN
{
	printf("%3s %6s %-16s -- %s\n", "C", "PID", "TIME(us)", "PROCEDURE");
}

tcl*:::proc-entry
{
	printf("%3d %6d %-16d %*s-> %s\n", cpu, pid, timestamp / 1000,
	self->depth * 2, "", copyinstr(arg0));
	self->depth++;
}

tcl*:::proc-return
{
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %-16d %*s<- %s\n", cpu, pid, timestamp / 1000,
	    self->depth * 2, "", copyinstr(arg0));
}
