#!/usr/sbin/dtrace -s
/*
 * httpio.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	trace("Tracing HTTP... Hit Ctrl-C for report.\n");
}

http*:::request-done
{
	@["received bytes"] = quantize(args[1]->hri_bytesread);
	@["sent bytes"] = quantize(args[1]->hri_byteswritten);
}
