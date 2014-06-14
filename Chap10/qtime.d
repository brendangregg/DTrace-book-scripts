#!/usr/sbin/dtrace -s
/*
 * qtime.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

sched:::enqueue
{
	a[args[0]->pr_lwpid, args[1]->pr_pid, args[2]->cpu_id] =
	    timestamp;
}

sched:::dequeue
/a[args[0]->pr_lwpid, args[1]->pr_pid, args[2]->cpu_id]/
{
	@[args[2]->cpu_id] = quantize(timestamp -
	    a[args[0]->pr_lwpid, args[1]->pr_pid, args[2]->cpu_id]);
	a[args[0]->pr_lwpid, args[1]->pr_pid, args[2]->cpu_id] = 0;
}
