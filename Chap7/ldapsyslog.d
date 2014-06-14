#!/usr/sbin/dtrace -s
/*
 * ldapsyslog.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN { printf("Tracing PID %d...\n", $target); }

pid$target::syslog:entry
{
	self->in_syslog = 1;
}

pid$target::strlen:entry
/self->in_syslog/
{
	self->buf = arg0;
}

pid$target::syslog:return
/self->buf/
{
	trace(copyinstr(self->buf));
	self->in_syslog = 0;
	self->buf = 0;
}
