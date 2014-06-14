#!/usr/sbin/dtrace -s
/*
 * readtype.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

inline int TOP = 20;
self int trace;
uint64_t lbytes;
uint64_t pbytes;

dtrace:::BEGIN
{
	trace("Tracing... Output every 5 secs, or Ctrl-C.\n");
}

fsinfo:::read
{
	@io[args[0]->fi_mount, "logical"] = count();
	@bytes[args[0]->fi_mount, "logical"] = sum(arg1);
	lbytes += arg1;
}

io:::start
/args[0]->b_flags & B_READ/
{
	@io[args[2]->fi_mount, "physical"] = count();
	@bytes[args[2]->fi_mount, "physical"] = sum(args[0]->b_bcount);
	pbytes += args[0]->b_bcount;
}

profile:::tick-5s,
dtrace:::END
{
	trunc(@io, TOP);
	trunc(@bytes, TOP);
	printf("\n%Y:\n", walltimestamp);
	printf("\n Read I/O (top %d)\n", TOP);
	printa(" %-32s %10s %10@d\n", @io);
	printf("\n Read Bytes (top %d)\n", TOP);
	printa(" %-32s %10s %10@d\n", @bytes);
	printf("\nphysical/logical bytes rate: %d%%\n",
	    lbytes ? 100 * pbytes / lbytes : 0);
	trunc(@bytes);
	trunc(@io);
	lbytes = pbytes = 0;
}
