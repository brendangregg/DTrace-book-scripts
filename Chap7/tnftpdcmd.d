#!/usr/sbin/dtrace -s
/*
 * tnftpdcmd.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
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
	printf("%-20s %10s  %s\n", "TIME", "LAT(us)", "FTP CMD");
}

pid$target:ftpd:getline:return
/arg1 && arg1 != 1/
{
	self->line = copyinstr(arg1);
	self->start = timestamp;
}

pid$target:ftpd:getline:entry
/self->start/
{
	this->delta = (timestamp - self->start) / 1000;
	/* self->line already contains "\r\n" */
	printf("%-20Y %10d  %s", walltimestamp, this->delta, self->line);
	self->start = 0;
	self->line = 0;
}
