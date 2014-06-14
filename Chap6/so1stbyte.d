#!/usr/sbin/dtrace -s
/*
 * so1stbyte.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
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
	printf("  %6s %-16s %6s  %14s %14s  %8s\n", "PID", "PROCESS", "PORT",
	    "CONNECT(us)", "1stBYTE(us)", "BYTES");
}

syscall::connect*:entry
{
	this->s = (struct sockaddr_in *)copyin(arg1, sizeof (struct sockaddr));
	self->port = (this->s->sin_port & 0xFF00) >> 8;
	self->port |= (this->s->sin_port & 0xFF) << 8;
	self->start = timestamp;
	self->connected = 0;
}

syscall::connect*:return
{
	self->connection = (timestamp - self->start) / 1000;
	self->start = 0;
	self->connected = timestamp;
}

syscall::read*:entry,
syscall::recv*:entry
/(fds[arg0].fi_fs == "sockfs" || fds[arg0].fi_name == "<socket>") &&
    self->connected/
{
	self->socket = 1;
}

syscall::read*:return,
syscall::recv*:return
/self->socket && arg0 > 0/
{
	this->firstbyte = (timestamp - self->connected) / 1000;
	printf("  %6d %-16s %6d  %14d %14d  %8d\n", pid, execname, self->port,
	    self->connection, this->firstbyte, arg0);
	self->connected = 0;
	self->socket = 0;
	self->port = 0;
}
