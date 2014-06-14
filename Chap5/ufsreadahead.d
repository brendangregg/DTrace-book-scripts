#!/usr/sbin/dtrace -s
/*
 * ufsreadahead.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

fbt::ufs_getpage:entry
{
	@["UFS read (bytes)"] = sum(arg2);
}

fbt::ufs_getpage_ra:return
{
	@["UFS read ahead (bytes)"] = sum(arg1);
}
