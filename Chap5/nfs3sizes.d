#!/usr/sbin/dtrace -s
/*
 * nfs3sizes.d
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
	trace("Tracing NFSv3 client file reads... Hit Ctrl-C to end.\n");
}

fbt::nfs3_read:entry
{
	@q["NFS read size (bytes)"] = quantize(args[1]->uio_resid);
	@s["NFS read (bytes)"] = sum(args[1]->uio_resid);
}

fbt::nfs3_directio_read:entry
{
	@q["NFS network read size (bytes)"] = quantize(args[1]->uio_resid);
	@s["NFS network read (bytes)"] = sum(args[1]->uio_resid);
}

fbt::nfs3_getpage:entry
{
	@q["NFS network read size (bytes)"] = quantize(arg2);
	@s["NFS network read (bytes)"] = sum(arg2);
}
