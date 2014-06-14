#!/usr/sbin/dtrace -s
/*
 * nfsv3disk.d
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
	interval = 5;
	printf("Tracing... Interval %d secs.\n", interval);
	tick = interval;
}

/* NFSv3 read/write */
nfsv3:::op-read-done { @nfsrb = sum(args[2]->res_u.ok.data.data_len); }
nfsv3:::op-write-done { @nfswb = sum(args[2]->res_u.ok.count); }

/* Disk read/write */
io:::done /args[0]->b_flags & B_READ/ { @diskrb = sum(args[0]->b_bcount); }
io:::done /args[0]->b_flags & B_WRITE/ { @diskwb = sum(args[0]->b_bcount); }

/* Filesystem hit rate: ZFS */
sdt:zfs::arc-hit { @fshit = count(); }
sdt:zfs::arc-miss { @fsmiss = count(); }

profile:::tick-1sec
/--tick == 0/
{
	normalize(@nfsrb, 1024 * interval);
	normalize(@nfswb, 1024 * interval);
	normalize(@diskrb, 1024 * interval);
	normalize(@diskwb, 1024 * interval);
	normalize(@fshit, interval);
	normalize(@fsmiss, interval);
	printf("\n   %10s %10s %10s %10s    %10s %10s\n", "NFS kr/s",
	    "ZFS hit/s", "ZFS miss/s", "Disk kr/s", "NFS kw/s", "Disk kw/s");
	printa("   %@10d %@10d %@10d %@10d    %@10d %@10d\n", @nfsrb, @fshit,
	    @fsmiss, @diskrb, @nfswb, @diskwb);
	trunc(@nfsrb); trunc(@nfswb); trunc(@diskrb); trunc(@diskwb);
	trunc(@fshit); trunc(@fsmiss);
	tick = interval;
}
