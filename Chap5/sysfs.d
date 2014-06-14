#!/usr/sbin/dtrace -Zs
/*
 * sysfs.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

/* trace read() variants, but not readlink() or __pthread*() (macosx) */
syscall::read:entry,
syscall::readv:entry,
syscall::pread*:entry,
syscall::*read*nocancel:entry,
syscall::*write*:entry
{
	@[execname, probefunc, fds[arg0].fi_mount] = count();
}

dtrace:::END
{
	printf("  %-16s %-16s %-30s %7s\n", "PROCESS", "SYSCALL",
	    "MOUNTPOINT", "COUNT");
	printa("  %-16s %-16s %-30s %@7d\n", @);
}
