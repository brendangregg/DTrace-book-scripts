#!/usr/sbin/dtrace -s
/*
 * sshdactivity.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-20s  %-8s %-8s %-8.8s %s\n", "TIME", "UID", "PID",
	    "ACTION", "ARGS");
	my_sshd = $1;
}

syscall::write*:entry
/execname == "sshd" && fds[arg0].fi_fs == "sockfs" && pid != my_sshd/
{
	printf("%-20Y  %-8d %-8d %-8.8s %d bytes\n", walltimestamp, uid, pid,
	    probefunc, arg2);
}

syscall::accept*:return
/execname == "sshd"/
{
	printf("%-20Y  %-8d %-8d %-8.8s %s\n", walltimestamp, uid, pid,
	    probefunc, "CONNECTION STARTED");
}
