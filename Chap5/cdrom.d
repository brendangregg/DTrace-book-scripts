#!/usr/sbin/dtrace -Zs
/*
 * cdrom.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
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
	trace("Tracing hsfs (cdrom) mountfs...\n");
}

fbt::hs_mountfs:entry
{
	printf("%Y:  Mounting %s... ", walltimestamp, stringof(arg2));
	self->start = timestamp;
}

fbt::hs_mountfs:return
/self->start/
{
	this->time = (timestamp - self->start) / 1000000;
	printf("result: %d%s, time: %d ms\n", arg1,
	    arg1 ? "" : " (SUCCESS)", this->time);
	self->start = 0;
}
