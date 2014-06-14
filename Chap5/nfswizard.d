#!/usr/sbin/dtrace -s
/*
 * nfswizard.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
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
	scriptstart = walltimestamp;
	timestart = timestamp;
}

io:nfs::start
{
	/* tally file sizes */
	@file[args[2]->fi_pathname] = sum(args[0]->b_bcount);

	/* time response */
	start[args[0]->b_addr] = timestamp;

	/* overall stats */
	@rbytes = sum(args[0]->b_flags & B_READ ? args[0]->b_bcount : 0);
	@wbytes = sum(args[0]->b_flags & B_READ ? 0 : args[0]->b_bcount);
	@events = count();
}

io:nfs::done
/start[args[0]->b_addr]/
{
	/* calculate and save response time stats */
	this->elapsed = timestamp - start[args[0]->b_addr];
	@maxtime = max(this->elapsed);
	@avgtime = avg(this->elapsed);
	@qnztime = quantize(this->elapsed / 1000);
}

dtrace:::END
{
	/* print header */
	printf("NFS Client Wizard. %Y -> %Y\n\n", scriptstart, walltimestamp);

	/* print read/write stats */
	printa("Read:  %@d bytes ", @rbytes);
	normalize(@rbytes, 1000000);
	printa("(%@d Mb)\n", @rbytes);
	printa("Write: %@d bytes ", @wbytes);
	normalize(@wbytes, 1000000);
	printa("(%@d Mb)\n\n", @wbytes);

	/* print throughput stats */
	denormalize(@rbytes);
	normalize(@rbytes, (timestamp - timestart) / 1000000);
	printa("Read:  %@d Kb/sec\n", @rbytes);
	denormalize(@wbytes);
	normalize(@wbytes, (timestamp - timestart) / 1000000);
	printa("Write: %@d Kb/sec\n\n", @wbytes);

	/* print time stats */
	printa("NFS I/O events:    %@d\n", @events);
	normalize(@avgtime, 1000000);
	printa("Avg response time: %@d ms\n", @avgtime);
	normalize(@maxtime, 1000000);
	printa("Max response time: %@d ms\n\n", @maxtime);
	printa("Response times (us):%@d\n", @qnztime);

	/* print file stats */
	printf("Top 25 files accessed (bytes):\n");
	printf("   %-64s %s\n", "PATHNAME", "BYTES");
	trunc(@file, 25);
	printa("   %-64s %@d\n", @file);
}
