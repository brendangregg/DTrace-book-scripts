#!/usr/sbin/dtrace -s
/*
 * networkwho.d
 *
 * Example script from Chapter 11 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option defaultargs
#pragma D option switchrate=10hz

dtrace:::BEGIN
/$1 == 0/
{
	printf("USAGE: networkwho.d PID\n");
	exit(1);
}

syscall::connect:entry,
syscall::listen:entry
/pid == $1/
{
	ustack();
}

syscall::write*:entry,
syscall::send*:entry
/pid == $1/
{
	trace(fds[arg0].fi_fs);
	ustack();
}
