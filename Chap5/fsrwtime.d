#!/usr/sbin/dtrace -Zs
/*
 * fsrwtime.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

/* trace read() variants, but not readlink() or __pthread*() (macosx) */
syscall::read:entry,
syscall::readv:entry,
syscall::pread*:entry,
syscall::*read*nocancel:entry,
syscall::*write*:entry
{
	self->fd = arg0;
	self->start = timestamp;
}

syscall::*read*:return,
syscall::*write*:return
/self->start/
{
	this->delta = (timestamp - self->start) / 1000;
	@[fds[self->fd].fi_fs, probefunc, fds[self->fd].fi_mount] =
	    quantize(this->delta);
	self->fd = 0; self->start = 0;
}

dtrace:::END
{
	printa("\n  %s %s (us) \t%s%@d", @);
}
