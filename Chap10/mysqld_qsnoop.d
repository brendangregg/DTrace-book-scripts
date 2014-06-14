#!/usr/sbin/dtrace -s
/*
 * mysqld_qsnoop.d
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
	printf("%-8s %-16s %-18s %5s %3s %s\n", "TIME(ms)", "DATABASE",
	    "USER@HOST", "ms", "RET", "QUERY");
	timezero = timestamp;
}

mysql*:::query-start
{
	self->query = copyinstr(arg0);
	self->db = copyinstr(arg2);
	self->who = strjoin(copyinstr(arg3), strjoin("@", copyinstr(arg4)));
	self->start = timestamp;
}

mysql*:::query-done
/self->start/
{
	this->now = (timestamp - timezero) / 1000000;
	this->time = (timestamp - self->start) / 1000000;
	printf("%-8d %-16.16s %-18.18s %5d %3d %s\n", this->now, self->db,
	    self->who, this->time, (int)arg0, self->query);
	self->start = 0; self->query = 0; self->db = 0; self->who = 0;
}
