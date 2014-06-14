#!/usr/sbin/dtrace -s
/*
 * nfsv4commit.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

/* From /usr/include/nfs/nfs4_kprot.h */
inline int UNSTABLE = 0;
int last[string];

dtrace:::BEGIN
{
	printf("Tracing NFSv4 writes and commits... Hit Ctrl-C to end.\n");
}

nfsv4:::op-write-start
/args[2]->stable == UNSTABLE/
{
	@write[args[1]->noi_curpath] = sum(args[2]->data_len);
}

nfsv4:::op-write-start
/args[2]->stable != UNSTABLE/
{
	@syncwrite[args[1]->noi_curpath] = sum(args[2]->data_len);
}

nfsv4:::op-commit-start
/(this->last = last[args[1]->noi_curpath])/
{
	this->delta = (timestamp - this->last) / 1000;
	@time[args[1]->noi_curpath] = quantize(this->delta);
}

nfsv4:::op-commit-start
{
	@committed[args[1]->noi_curpath] = sum(args[2]->count);
	@commit[args[1]->noi_curpath] = quantize(args[2]->count / 1024);
	last[args[1]->noi_curpath] = timestamp;
}

dtrace:::END
{
	normalize(@write, 1024);
	normalize(@syncwrite, 1024);
	normalize(@committed, 1024);
	printf("\nCommited vs uncommited written Kbytes by path:\n\n");
	printf(" %-10s %-10s %-10s %s\n", "WRITE", "SYNCWRITE", "COMMITTED",
	    "PATH");
	printa(" %@-10d %@-10d %@-10d %s\n", @write, @syncwrite, @committed);
	printf("\n\nCommit Kbytes by path:\n");
	printa(@commit);
	printf("\nTime between commits (us) by path:\n");
	printa(@time);
}
