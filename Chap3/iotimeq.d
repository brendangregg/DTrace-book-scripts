#!/usr/sbin/dtrace -s
/*
 * iotimeq.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN { trace("Tracing...Output afer 10 seconds, or Ctrl-C\n"); }

io:::start
{
	start[args[0]->b_edev, args[0]->b_blkno] = timestamp;
}

io:::done
/start[args[0]->b_edev, args[0]->b_blkno]/
{
	this->elapsed =
	    (timestamp - start[args[0]->b_edev, args[0]->b_blkno]) / 1000000;
	@iot[args[1]->dev_statname,
	    args[0]->b_flags & B_READ ? "READS(ms)" : "WRITES(ms)"] =
	    quantize(this->elapsed);
	start[args[0]->b_edev, args[0]->b_blkno] = 0;
}
tick-10sec
{
	printa(@iot);
	exit(0);
}
