#!/usr/sbin/dtrace -s
/*
 * pg_qslower.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-8s %5s %5s %5s %s\n", "TIMEms", "QRYms", "EXCms", "CPUms",
	    "QUERY");
	min_ns = $1 * 1000000;
	timezero = timestamp;
}

postgresql*:::query-start
{
	self->start = timestamp;
	self->vstart = vtimestamp;
}

postgresql*:::query-execute-start
{
	self->estart = timestamp;
}

postgresql*:::query-execute-done
/self->estart/
{
	self->exec = timestamp - self->estart;
	self->estart = 0;
}

postgresql*:::query-done
/self->start && (timestamp - self->start) >= min_ns/
{
	this->now = (timestamp - timezero) / 1000000;
	this->time = (timestamp - self->start) / 1000000;
	this->vtime = (vtimestamp - self->vstart) / 1000000;
	this->etime = self->exec / 1000000;
	printf("%-8d %5d %5d %5d %s\n", this->now, this->time, this->etime,
	    this->vtime, copyinstr(arg0));
}

postgresql*:::query-done
{
	self->start = 0; self->vstart = 0; self->exec = 0;
}
