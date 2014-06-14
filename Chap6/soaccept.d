#!/usr/sbin/dtrace -s
/*
 * soaccept.d
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
	/* Add translations as desired from /usr/include/sys/errno.h */
	err[0]            = "Success";
	err[EINTR]        = "Interrupted syscall";
	err[EIO]          = "I/O error";
	err[EAGAIN]       = "Resource temp unavail";
	err[EACCES]       = "Permission denied";
	err[ECONNABORTED] = "Connection aborted";
	err[ECONNRESET]   = "Connection reset";
	err[ETIMEDOUT]    = "Timed out";
	err[EINPROGRESS]  = "In progress";

	printf("%-6s %-16s %-3s %-16s %-5s %8s %s\n", "PID", "PROCESS", "FAM",
	    "ADDRESS", "PORT", "LAT(us)", "RESULT");
}

syscall::accept*:entry
{
	self->sa = arg1;
	self->start = timestamp;
}

syscall::accept*:return
/self->sa/
{
	this->delta = (timestamp - self->start) / 1000;
	/* assume this is sockaddr_in until we can examine family */
	this->s = (struct sockaddr_in *)copyin(self->sa,
	    sizeof (struct sockaddr_in));
	this->f = this->s->sin_family;
}

syscall::accept*:return
/this->f == af_inet/
{
	this->port = ntohs(this->s->sin_port);
	this->address = inet_ntoa((ipaddr_t *)&this->s->sin_addr);
	this->errstr = err[errno] != NULL ? err[errno] : lltostr(errno);
	printf("%-6d %-16s %-3d %-16s %-5d %8d %s\n", pid, execname,
	    this->f, this->address, this->port, this->delta, this->errstr);
}

syscall::accept*:return
/this->f == af_inet6/
{
	/* refetch for sockaddr_in6 */
	this->s6 = (struct sockaddr_in6 *)copyin(self->sa,
	    sizeof (struct sockaddr_in6));
	this->port = ntohs(this->s6->sin6_port);
	this->address = inet_ntoa6((in6_addr_t *)&this->s6->sin6_addr);
	this->errstr = err[errno] != NULL ? err[errno] : lltostr(errno);
	printf("%-6d %-16s %-3d %-16s %-5d %8d %s\n", pid, execname,
	    this->f, this->address, this->port, this->delta, this->errstr);
}

syscall::accept*:return
/self->start/
{
	self->sa = 0; self->start = 0;
}
