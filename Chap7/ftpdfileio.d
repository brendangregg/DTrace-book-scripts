#!/usr/sbin/dtrace -Zs
/*
 * ftpdfileio.d
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
	printf("Tracing... Hit Ctrl-C to end.\n");
}

ftp*:::transfer-done
{
	@[args[1]->fti_cmd, args[1]->fti_pathname] = sum(args[1]->fti_nbytes);
}

dtrace:::END
{
	printf("\n%8s %12s  %s\n", "DIR", "BYTES", "PATHNAME");
	printa("%8s %@12d  %s\n", @);
}
