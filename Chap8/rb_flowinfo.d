#!/usr/sbin/dtrace -Zs
/*
 * rb_flowinfo.d
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
	printf("%s %6s %10s  %16s:%-4s %-8s -- %s\n", "C", "PID", "DELTA(us)",
	    "FILE", "LINE", "TYPE", "NAME");
}

ruby*:::function-entry,
ruby*:::function-return
/self->last == 0/
{
	self->last = timestamp;
}

ruby*:::function-entry
{
	this->delta = (timestamp - self->last) / 1000;
	this->name = strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1));
	printf("%d %6d %10d  %16s:%-4d %-8s %*s-> %s\n", cpu, pid, this->delta,
	    basename(copyinstr(arg2)), arg3, "method", self->depth * 2, "",
	    this->name);
	self->depth++;
	self->last = timestamp;
}

ruby*:::function-return
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	this->name = strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1));
	printf("%d %6d %10d  %16s:%-4d %-8s %*s<- %s\n", cpu, pid, this->delta,
	    basename(copyinstr(arg2)), arg3, "method", self->depth * 2, "",
	this->name);
	self->last = timestamp;
}
