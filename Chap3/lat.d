#!/usr/sbin/dtrace -s
/*
 * lat.d
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
{
	s[args[0]->pr_lwpid, args[1]->pr_pid] = timestamp;
}

sched:::dequeue
/this->start = s[args[0]->pr_lwpid, args[1]->pr_pid]/
{
	this->time = timestamp - this->start;
	@lat_avg[args[2]->cpu_id] = avg(this->time);
	@lat_max[args[2]->cpu_id] = max(this->time);
	@lat_min[args[2]->cpu_id] = min(this->time);
	s[args[0]->pr_lwpid, args[1]->pr_pid] = 0;

}
tick-1sec
{
	printf("%-8s %-12s %-12s %-12s\n",
	    "CPU", "AVG(ns)", "MAX(ns)", "MIN(ns)");
	printa("%-8d %-@12d %-@12d %-@12d\n", @lat_avg, @lat_max, @lat_min);
	trunc(@lat_avg); trunc(@lat_max); trunc(@lat_min);
}
