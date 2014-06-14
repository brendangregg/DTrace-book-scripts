#!/usr/sbin/dtrace -s
/*
 * soerrors.d
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
	/* Add translations as desired from /usr/include/sys/errno.h */
	err[0]            = "Success";
	err[EACCES]       = "Permission denied";
	err[ECONNABORTED] = "Connection abort";
	err[ECONNREFUSED] = "Connection refused";
	err[ECONNRESET]   = "Connection reset";
	err[EHOSTDOWN]    = "Host down";
	err[EHOSTUNREACH] = "No route to host";
	err[EINPROGRESS]  = "In progress";
	err[EINTR]        = "Interrupted syscall";
	err[EINVAL]       = "Invalid argument";
	err[EIO]          = "I/O error";
	err[ENETDOWN]     = "Network is down";
	err[ENETUNREACH]  = "Network unreachable";
	err[EPROTO]       = "Protocol error";
	err[ETIMEDOUT]    = "Timed out";
	err[EWOULDBLOCK]  = "Would block";

	printf("  %-6s %-16s %-10s %-4s %4s %4s  %s\n", "PID", "PROCESS",
	    "SYSCALL", "FD", "RVAL", "ERR", "RESULT");
}

syscall::connect*:entry,
syscall::accept*:entry,
syscall::getsockopt:entry,
syscall::setsockopt:entry
{
	self->fd = arg0; self->ok = 1;
}

syscall::read*:entry,
syscall::write*:entry,
syscall::send*:entry,
syscall::recv*:entry
/fds[arg0].fi_fs == "sockfs" || fds[arg0].fi_name == "<socket>"/
{
	self->fd = arg0; self->ok = 1;
}

syscall::so*:entry
{
	self->ok = 1;
}

syscall::connect*:return,
syscall::accept*:return,
syscall::read*:return,
syscall::write*:return,
syscall::send*:return,
syscall::recv*:return,
syscall::getsockopt:return,
syscall::setsockopt:return
/errno != 0 && errno != EAGAIN && self->ok/
{
	this->errstr = err[errno] != NULL ? err[errno] : lltostr(errno);
	printf("  %-6d %-16s %-10s %-4d %4d %4d  %s\n", pid, execname,
	    probefunc, self->fd, arg0, errno, this->errstr);
}

syscall::so*:return
/errno != 0/
{
	/* these syscalls (such as sockconfig) don't operate on socket fds */
	this->errstr = err[errno] != NULL ? err[errno] : lltostr(errno);
	printf("  %-6d %-16s %-10s %-4s %4d %4d  %s\n", pid, execname,
	    probefunc, "-", arg0, errno, this->errstr);
}

syscall::connect*:return,
syscall::accept*:return,
syscall::read*:return,
syscall::write*:return,
syscall::send*:return,
syscall::recv*:return,
syscall::getsockopt:return,
syscall::setsockopt:return,
syscall::so*:return
{
	self->fd = 0; self->ok = 0;
}
