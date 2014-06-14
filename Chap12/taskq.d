#!/usr/sbin/dtrace -s
/*
 * taskq.d
 *
 * Example script from Chapter 12 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN { trace("Tracing...  Interval 10 seconds, or Ctrl-C.\n"); }

sdt:::taskq-enqueue
{
	this->tq  = (taskq_t *)arg0;
	this->tqe = (taskq_ent_t *)arg1;
	@c[this->tq->tq_name, this->tqe->tqent_func] = count();
	time[arg1] = timestamp;
}

sdt:::taskq-exec-start
/time[arg1]/
{
	this->wait = timestamp - time[arg1];
	this->tq  = (taskq_t *)arg0;
	this->tqe = (taskq_ent_t *)arg1;
	@w[this->tq->tq_name, this->tqe->tqent_func] = sum(this->wait);
	time[arg1] = timestamp;
}

sdt:::taskq-exec-end
/time[arg1]/
{
	this->exec = timestamp - time[arg1];
	this->tq  = (taskq_t *)arg0;
	this->tqe = (taskq_ent_t *)arg1;
	@e[this->tq->tq_name, this->tqe->tqent_func] = sum(this->exec);
	time[arg1] = 0;
}

profile:::tick-10s,
dtrace:::END
{
	normalize(@w, 1000000);
	normalize(@e, 1000000);
	printf("\n %-22s %-25s %8s %9s %9s\n", "TASKQ NAME", "FUNCTION",
	    "COUNT", "T_WAITms", "T_EXECms");
	printa(" %-22.22s %-25.25a %8@d %@9d %@9d\n", @c, @w, @e);
	trunc(@c); trunc(@w); trunc(@e);
}
