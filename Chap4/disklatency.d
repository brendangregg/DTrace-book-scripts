#!/usr/sbin/dtrace -s
/*
 * disklatency.d
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
/this->start = start_time[arg0]/
{
	this->delta = (timestamp - this->start) / 1000;
	@[args[1]->dev_statname, args[1]->dev_major, args[1]->dev_minor] =
	    quantize(this->delta);
	start_time[arg0] = 0;
}

dtrace:::END
{
	printa("   %s (%d,%d), us:\n%@d\n", @);
}
