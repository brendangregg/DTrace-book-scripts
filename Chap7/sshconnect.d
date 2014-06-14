#!/usr/sbin/dtrace -Zs
/*
 * sshconnect.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN { trace("Tracing next ssh connect...\n"); }

/*
 * Tracing begins here: ssh process executed
 */
proc:::exec-success
/execname == "ssh"/
{
	self->start = timestamp;
	self->vstart = vtimestamp;
}
syscall:::entry
/self->start/
{
	self->syscall = timestamp;
	self->arg = "";
}

/*
 * Include syscall argument details when potentially interesting
 */
syscall::read*:entry,
syscall::ioctl*:entry,
syscall::door*:entry,
syscall::recv*:entry
/self->start/
{
	self->arg = fds[arg0].fi_pathname;
}

/*
 * Measure network I/O as pollsys/select->read() time after connect()
 */
syscall::connect:entry
/self->start && !self->socket/
{
	self->socket = arg0;
	self->connect = 1;
	self->vconnect = vtimestamp;
}
syscall::pollsys:entry,
syscall::select:entry
/self->connect/
{
	self->wait = timestamp;
}
syscall::read*:return
/self->wait/
{
	@network = sum(timestamp - self->wait);
	self->wait = 0;
}

syscall:::return
/self->syscall/
{
	@time[probefunc, self->arg] = sum(timestamp - self->syscall);
	self->syscall = 0; self->network = 0; self->arg = 0;
}

/*
 * Tracing ends here: writing of the "Password:" prompt (10 chars)
 */
syscall::write*:entry
/self->connect && arg0 != self->socket && arg2 == 10 &&
	stringof(copyin(arg1, 10)) == "Password: "/
{
	trunc(@time, 5);
	normalize(@time, 1000000);
	normalize(@network, 1000000);
	this->oncpu1 = (self->vconnect - self->vstart) / 1000000;
	this->oncpu2 = (vtimestamp - self->vconnect) / 1000000;
	this->elapsed = (timestamp - self->start) / 1000000;

	printf("\nProcess     : %s\n", curpsinfo->pr_psargs);
	printf("Elapsed     : %d ms\n", this->elapsed);
	printf("on-CPU pre  : %d ms\n", this->oncpu1);
	printf("on-CPU post : %d ms\n", this->oncpu2);
	printa("Network I/O : %@d ms\n", @network);
	printf("\nTop 5 syscall times\n");
	printa("%@8d ms : %s %s\n", @time);

	exit(0);
}

proc:::exit
/self->start/
{
	printf("\nssh process aborted: %s\n", curpsinfo->pr_psargs);
	trunc(@time); trunc(@network); exit(0);
}
