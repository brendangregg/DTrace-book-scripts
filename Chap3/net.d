#!/usr/sbin/dtrace -s
/*
 * net.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

syscall::*read:entry,
syscall::*write:entry
/fds[arg0].fi_fs == "sockfs"/
{
	@ior[probefunc] = count();
	@net_bytes[probefunc] = sum(arg2);
}
tick-1sec
{
	printf("%-8s %-16s %-16s\n", "FUNC", "OPS PER SEC", "BYTES PER SEC");
	printa("%-8s %-@16d %-@16d\n", @ior, @net_bytes);
	trunc(@ior); trunc(@net_bytes);
	printf("\n");
}
