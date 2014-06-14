#!/usr/sbin/dtrace -s
/*
 * superping.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

mib:::rawipOutDatagrams
/pid == $target/
{
	start = timestamp;
}

mib:::icmpInEchoReps
/start/
{
	this->delta = (timestamp - start) / 1000;
	printf("dtrace measured: %d us\n", this->delta);
	@a["\n  ICMP packet delta average (us):"] = avg(this->delta);
	@q["\n  ICMP packet delta distribution (us):"] =
	    lquantize(this->delta, 0, 1000000, 100);
	start = 0;
}
