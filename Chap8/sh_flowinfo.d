#!/usr/sbin/dtrace -Zs
/*
 * sh_flowinfo.d
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
	self->depth = 0;
	printf("%3s %6s %10s  %16s:%-4s %-8s -- %s\n", "C", "PID", "DELTA(us)",
	    "FILE", "LINE", "TYPE", "NAME");
}

sh*:::function-entry,
sh*:::function-return,
sh*:::builtin-entry,
sh*:::builtin-return,
sh*:::command-entry,
sh*:::command-return,
sh*:::subshell-entry,
sh*:::subshell-return
/self->last == 0/
{
	self->last = timestamp;
}

sh*:::function-entry
{
	this->delta = (timestamp - self->last) / 1000;
	printf("%3d %6d %10d  %16s:%-4d %-8s %*s-> %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), arg2, "func",
	    self->depth * 2, "", copyinstr(arg1));
	self->depth++;
	self->last = timestamp;
}

sh*:::function-return
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %10d  %16s:-    %-8s %*s<- %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), "func", self->depth * 2,
	    "", copyinstr(arg1));
	self->last = timestamp;
}

sh*:::builtin-entry
{
	this->delta = (timestamp - self->last) / 1000;
	printf("%3d %6d %10d  %16s:%-4d %-8s %*s-> %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), arg2, "builtin",
	    self->depth * 2, "", copyinstr(arg1));
	self->depth++;
	self->last = timestamp;
}

sh*:::builtin-return
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %10d  %16s:-    %-8s %*s<- %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), "builtin",
	self->depth * 2, "", copyinstr(arg1));
	self->last = timestamp;
}

sh*:::command-entry
{
	this->delta = (timestamp - self->last) / 1000;
	printf("%3d %6d %10d  %16s:%-4d %-8s %*s-> %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), arg2, "cmd",
	    self->depth * 2, "", copyinstr(arg1));
	self->depth++;
	self->last = timestamp;
}

sh*:::command-return
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %10d  %16s:-    %-8s %*s<- %s\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), "cmd",
	    self->depth * 2, "", copyinstr(arg1));
	self->last = timestamp;
}

sh*:::subshell-entry
/arg1 != 0/
{
	this->delta = (timestamp - self->last) / 1000;
	printf("%3d %6d %10d  %16s:-    %-8s %*s-> pid %d\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), "subsh",
	    self->depth * 2, "", arg1);
	self->depth++;
	self->last = timestamp;
}

sh*:::subshell-return
/self->last/
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %10d  %16s:-    %-8s %*s<- = %d\n", cpu, pid,
	    this->delta, basename(copyinstr(arg0)), "subsh",
	    self->depth * 2, "", arg1);
	self->last = timestamp;
}
