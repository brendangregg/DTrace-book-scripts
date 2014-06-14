#!/usr/sbin/dtrace -s
/*
 * nfsv4rwtime.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

inline int TOP_FILES = 10;

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

nfsv4:::op-read-start,
nfsv4:::op-write-start
{
	start[args[1]->noi_xid] = timestamp;
}

nfsv4:::op-read-done,
nfsv4:::op-write-done
/start[args[1]->noi_xid] != 0/
{
	this->elapsed = timestamp - start[args[1]->noi_xid];
	@rw[probename == "op-read-done" ? "read" : "write"] =
	    quantize(this->elapsed / 1000);
	@host[args[0]->ci_remote] = sum(this->elapsed);
	@file[args[1]->noi_curpath] = sum(this->elapsed);
	start[args[1]->noi_xid] = 0;
}

dtrace:::END
{
	printf("NFSv4 read/write distributions (us):\n");
	printa(@rw);

	printf("\nNFSv4 read/write by host (total us):\n");
	normalize(@host, 1000);
	printa(@host);

	printf("\nNFSv4 read/write top %d files (total us):\n", TOP_FILES);
	normalize(@file, 1000);
	trunc(@file, TOP_FILES);
	printa(@file);
}
