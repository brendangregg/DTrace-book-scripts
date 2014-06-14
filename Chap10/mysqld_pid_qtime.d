#!/usr/sbin/dtrace -s
/*
 * mysqld_pid_qtime.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

pid$target::*dispatch_command*:entry
{
	self->query = copyinstr(arg2);
	self->start = timestamp;
}

pid$target::*dispatch_command*:return
/self->start/
{
	@time[self->query] = quantize(timestamp - self->start);
	self->query = 0; self->start = 0;
}

dtrace:::END
{
	printf("MySQL query execution latency (ns):\n");
	printa(@time);
}
