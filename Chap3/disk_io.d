#!/usr/sbin/dtrace -Cs
/*
 * disk_io.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

#define	PRINT_HDR printf("%-8s %-16s %-8s %-16s\n",
	"RPS", "RD BYTES", "WPS", "WR BYTES");

dtrace:::BEGIN
{
	PRINT_HDR
}

io:::start
/execname == $$1 && args[0]->b_flags & B_READ/
{
	@rps = count();
	@rbytes = sum(args[0]->b_bcount);
}

io:::start
/execname == $$1 && args[0]->b_flags & B_WRITE/
{
	@wps = count();
	@wbytes = sum(args[0]->b_bcount);
}
tick-1sec
{
	printa("%-@8d %-@16d %-@8d %-@16d\n", @rps, @rbytes, @wps, @wbytes);
	trunc(@rps); trunc(@rbytes); trunc(@wps); trunc(@wbytes);
}
tick-1sec
/x++ == 20/
{
	PRINT_HDR
	x = 0;
}
