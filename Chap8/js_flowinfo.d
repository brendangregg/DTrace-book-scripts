#!/usr/sbin/dtrace -Zs
/*
 * js_flowinfo.d
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
	printf("%3s %6s %10s  %16s:%-4s %-8s -- %s\n", "C", "PID", "DELTA(us)",
	    "FILE", "LINE", "TYPE", "FUNC");
}

javascript*:::function-info,
javascript*:::function-return
/self->last == 0/
{
	self->last = timestamp;
}

javascript*:::function-info
{
	this->delta = (timestamp - self->last) / 1000;
	printf("%3d %6d %10d  %16s:%-4d %-8s %*s-> %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg4)), arg5, "func",
	self->depth * 2, "", copyinstr(arg2));
	self->depth++;
	self->last = timestamp;
}

javascript*:::function-return
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %10d  %16s:-    %-8s %*s<- %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), "func", self->depth * 2,
	    "", copyinstr(arg2));
	self->last = timestamp;
}
