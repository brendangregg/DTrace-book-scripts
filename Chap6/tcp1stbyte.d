#!/usr/sbin/dtrace -s
/*
 * tcp1stbyte.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

tcp:::connect-established
{
	start[args[1]->cs_cid] = timestamp;
}

tcp:::receive
/start[args[1]->cs_cid] && (args[2]->ip_plength - args[4]->tcp_offset) > 0/
{
	@latency["1st Byte Latency (ns)", args[2]->ip_saddr] =
	    quantize(timestamp - start[args[1]->cs_cid]);
	start[args[1]->cs_cid] = 0;
}
