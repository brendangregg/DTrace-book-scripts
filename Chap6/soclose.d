#!/usr/sbin/dtrace -s
/*
 * soclose.d
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

/* If AF_INET and AF_INET6 are "Unknown" to DTrace, replace with numbers: */
inline int af_inet = AF_INET;
inline int af_inet6 = AF_INET6;

dtrace:::BEGIN
{
	printf("  %-6s %-16s %-3s %-16s %-5s %s\n", "PID", "PROCESS", "FAM",
	    "ADDRESS", "PORT", "DURATION(sec)");
}

syscall::connect*:entry
{
	this->s = (struct sockaddr_in *)copyin(arg1, sizeof (struct sockaddr));
	this->f = this->s->sin_family;
}

syscall::connect*:entry
/this->f == af_inet || this->f == af_inet6/
{
	self->family[arg0] = this->f;
	self->port[arg0] = ntohs(this->s->sin_port);
	self->address[arg0] = inet_ntop(this->s->sin_family,
	    (void *)&this->s->sin_addr);
	self->start[arg0] = timestamp;
}

syscall::close:entry
/self->start[arg0]/
{
	this->delta = (timestamp - self->start[arg0]) / 1000;
	this->sec = this->delta / 1000000;
	this->ms = (this->delta - (this->sec * 1000000)) / 1000;
	printf("  %-6d %-16s %-3d %-16s %-5d %d.%03d\n", pid, execname,
	    self->family[arg0], self->address[arg0], self->port[arg0],
	    this->sec, this->ms);
	self->family[arg0] = 0;
	self->address[arg0] = 0;
	self->port[arg0] = 0;
	self->start[arg0] = 0;
}
