#!/usr/sbin/dtrace -s
/*
 * httpclients.d
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
	trace("Tracing... output every 10 seconds, or Ctrl-C.\n");
}

http*:::request-done
{
	@rbytes[args[0]->ci_remote] = sum(args[1]->hri_bytesread);
	@wbytes[args[0]->ci_remote] = sum(args[1]->hri_byteswritten);
}

profile:::tick-10sec,
dtrace:::END
{
	normalize(@rbytes, 1024);
	normalize(@wbytes, 1024);
	printf("\n %-32s %10s %10s\n", "HTTP CLIENT", "FROM(KB)", "TO(KB)");
	printa(" %-32s %@10d %@10d\n", @rbytes, @wbytes);
	trunc(@rbytes);
	trunc(@wbytes);
}
