#!/usr/sbin/dtrace -s
/*
 * mmap.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option flowindent

syscall::mmap:entry
{
	self->flag = 1;
}
fbt:::
/self->flag/
{
}
syscall::mmap:return
/self->flag/
{
	self->flag = 0;
	exit(0);
}
