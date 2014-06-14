#!/usr/sbin/dtrace -s
/*
 * iolatency.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

io:::start
{
	start[arg0] = timestamp;
}

io:::done
/start[arg0]/
{
	@time["disk I/O latency (ns)"] = quantize(timestamp - start[arg0]);
	start[arg0] = 0;
}
