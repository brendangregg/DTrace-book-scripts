#!/usr/sbin/dtrace -s
/*
 * proftpdio.d
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
	interval = 5;
	printf("Tracing... Output every %d seconds.\n", interval);
	printf("  FTPD %4s %8s %8s %8s %8s %10s\n",
	    "r/s", "w/s", "kr/s", "kw/s", "cmd/s", "cmd_t(ms)");
	tick = interval;
	@readb = sum(0);		/* trigger output */
}

pid$target:proftpd:pr_netio_read:return
/arg1 > 0/
{
	@writes = count();
	@writeb = sum(arg1);
}

pid$target:proftpd:pr_netio_write:entry
/arg2 > 0/
{
	@reads = count();
	@readb = sum(arg2);
}

pid$target:proftpd:pr_netio_telnet_gets:return
{
	@cmds = count();
	self->start = timestamp;
}

pid$target:proftpd:pr_netio_telnet_gets:entry
{
	this->delta = (timestamp - self->start) / 1000000;
	@svct = avg(this->delta);
}

profile:::tick-1sec
/--tick == 0/
{
	normalize(@reads, interval);
	normalize(@readb, interval * 1024);
	normalize(@writes, interval);
	normalize(@writeb, interval * 1024);
	normalize(@cmds, interval);

	printa("   %@8d %@8d %@8d %@8d %@8d %@10d\n",
	@reads, @writes, @readb, @writeb, @cmds, @svct);

	clear(@reads); clear(@readb); clear(@writes); clear(@writeb);
	clear(@cmds); clear(@svct);
	tick = interval;
}
