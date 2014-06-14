#!/usr/sbin/dtrace -Zs
/*
 * libmysql_snoop.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
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
	printf("%-8s %6s %3s %s\n", "TIME(ms)", "Q(ms)", "RET", "QUERY");
	timezero = timestamp;
}

pid$target::mysql_query:entry,
pid$target::mysql_real_query:entry
{
	self->query = copyinstr(arg1);
	self->start = timestamp;
}

pid$target::mysql_query:return,
pid$target::mysql_real_query:return
/self->start/
{
	this->time = (timestamp - self->start) / 1000000;
	this->now = (timestamp - timezero) / 1000000;
	printf("%-8d %6d %3d %s\n", this->now, this->time, arg1, self->query);
	self->start = 0; self->query = 0;
}
