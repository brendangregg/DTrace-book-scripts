#!/usr/sbin/dtrace -s
/*
 * proftpdtime.d
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
	printf("Tracing... Hit Ctrl-C to end.\n");
}

/* on this proftpd version, pr_netio_telnet_gets() returns the FTP cmd */
pid$target:proftpd:pr_netio_telnet_gets:return
{
	self->cmd = copyinstr(arg1);
	self->start = timestamp;
}

pid$target:proftpd:pr_netio_telnet_gets:entry
/self->start/
{
	this->delta = (timestamp - self->start) / 1000000;
	@[self->cmd] = lquantize(this->delta, 0, 1000, 10);
	self->start = 0;
	self->cmd = 0;
}

dtrace:::END
{
	printf("FTP command times (ms):\n");
	printa(@);
}
