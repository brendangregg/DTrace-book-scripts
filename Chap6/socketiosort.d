#!/usr/sbin/dtrace -s
/*
 * socketiosort.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing Socket I/O... Hit Ctrl-C to end.\n");
}

syscall::read*:entry,
syscall::write*:entry,
syscall::send*:entry,
syscall::recv*:entry
/fds[arg0].fi_fs == "sockfs" || fds[arg0].fi_name == "<socket>"/
{
	@num[execname, probefunc, pid] = count();
	@pid[execname, probefunc, pid] = max(pid);
	@pid["--------------", "------", pid] = max(pid);
}

dtrace:::END
{
	printf("  %-8s %-16s %-16s %10s\n", "PID", "PROCESS", "SYSCALL",
	    "COUNT");
	setopt("aggsortpos", "0");
	printa("  %@-8d %-16s %-16s %@10d\n", @pid, @num);
}
