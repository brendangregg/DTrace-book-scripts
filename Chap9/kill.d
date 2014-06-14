#!/usr/sbin/dtrace -s
/*
 * kill.d
 *
 * Example script from Chapter 9 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("%-6s %12s %6s %-8s %s\n",
	    "FROM", "COMMAND", "SIG", "TO", "RESULT");
}

syscall::kill:entry
{
	self->target = (int)arg0;
	self->signal = arg1;
}

syscall::kill:return
{
	printf("%-6d %12s %6d %-8d %d\n",
	    pid, execname, self->signal, self->target, (int)arg0);
	self->target = 0;
	self->signal = 0;
}
