#!/usr/sbin/dtrace -s
/*
 * rwtime.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
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

io:::start
{
	start_time[arg0] = timestamp;
}

io:::done
/(args[0]->b_flags & B_READ) && (this->start = start_time[arg0])/
{
	this->delta = (timestamp - this->start) / 1000;
	@plots["read I/O, us"] = quantize(this->delta);
	@avgs["average read I/O, us"] = avg(this->delta);
	start_time[arg0] = 0;
}

io:::done
/!(args[0]->b_flags & B_READ) && (this->start = start_time[arg0])/
{
	this->delta = (timestamp - this->start) / 1000;
	@plots["write I/O, us"] = quantize(this->delta);
	@avgs["average write I/O, us"] = avg(this->delta);
	start_time[arg0] = 0;
}

dtrace:::END
{
	printa("   %s\n%@d\n", @plots);
	printa(@avgs);
}
