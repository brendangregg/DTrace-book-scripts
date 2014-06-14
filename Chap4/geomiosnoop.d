#!/usr/sbin/dtrace -s
/*
 * geomiosnoop.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

/* from /usr/src/sys/sys/bio.h */
inline int BIO_READ = 0x01;
inline int BIO_WRITE = 0x02;

dtrace:::BEGIN
{
	printf("%5s %5s %1s %10s %6s %16s %-8s %s\n", "UID", "PID", "D",
	    "OFFSET(KB)", "BYTES", "COMM", "VNODE", "INFO");
}

fbt::g_vfs_strategy:entry
{
	/* attempt to fetch the filename from the namecache */
	this->file = args[1]->b_vp->v_cache_dd != NULL ?
	    stringof(args[1]->b_vp->v_cache_dd->nc_name) : "<unknown>";
	printf("%5d %5d %1s %10d %6d %16s %-8x %s \n", uid, pid,
	    args[1]->b_iocmd & BIO_READ ? "R" : "W",
	    args[1]->b_iooffset / 1024, args[1]->b_bcount,
	    execname, (uint64_t)args[1]->b_vp, this->file);
}

fbt::g_dev_strategy:entry
{
	printf("%5d %5d %1s %10d %6d %16s %-8s %s\n", uid, pid,
	    args[0]->bio_cmd & BIO_READ ? "R" : "W",
	    args[0]->bio_offset / 1024, args[0]->bio_bcount,
	    execname, "<dev>", stringof(args[0]->bio_dev->si_name));
}
