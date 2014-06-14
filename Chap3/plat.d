#!/usr/sbin/dtrace -s
/*
 * plat.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */
#pragma D option quiet
sched:::enqueue
/args[1]->pr_pid == $target/
{
	s[args[2]->cpu_id] = timestamp;
}

sched:::dequeue
/s[args[2]->cpu_id]/
{
	@lat_sum[args[1]->pr_pid] = sum(timestamp - s[args[2]->cpu_id]);
	s[args[2]->cpu_id] = 0;
}

tick-1sec
{
	normalize(@lat_sum, 1000);
	printa("PROCESS: %d spent %@d microseconds waiting for a CPU\n",
	    @lat_sum);
	trunc(@lat_sum);
}
