#!/usr/sbin/dtrace -s
/*
 * rwa.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN { trace("Tracing... Output after 10 seconds, or Ctrl-C\n"); }

syscall::$1:entry
/execname == $$2/
{
	self->fd = arg0;
	self->st = timestamp;
}
syscall::$1:return
/self->st/
{
	@iot[pid, probefunc, fds[self->fd].fi_pathname] =
	    sum(timestamp - self->st);
	self->fd = 0;
	self->st = 0;
}
tick-10sec
{
	normalize(@iot, 1000);
	printf("%-8s %-8s %-32s %-16s\n",
	    "PID", "SYSCALL", "PATHNAME", "TIME(us)");
	printa("%-8d %-8s %-32s %-@16d\n", @iot);
}
