#! /usr/sbin/dtrace -qs
/*
 * rw_bytes.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

syscall::read:entry,
syscall::write:entry
/fds[arg0].fi_fs == "sockfs"/
{
	self->flag = 1
}
syscall::read:return,
syscall::write:return
/(int)arg0 != -1 && self->flag/
{
	@[probefunc] = sum(arg0);
}
syscall::read:return,
syscall::write:return
{
	self->flag = 0;
}
