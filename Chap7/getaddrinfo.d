#!/usr/sbin/dtrace -s
/*
 * getaddrinfo.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("%-20s  %-12s %s\n", "TIME", "LATENCY(ms)", "HOST");
}

pid$target::getaddrinfo:entry
{
	self->host = copyinstr(arg0);
	self->start = timestamp;
}

pid$target::getaddrinfo:return
/self->start/
{
	this->delta = (timestamp - self->start) / 1000000;
	printf("%-20Y  %-12d %s\n", walltimestamp, this->delta, self->host);
	self->host = 0;
	self->start = 0;
}
