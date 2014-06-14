#!/usr/sbin/dtrace -s
/*
 * cifsrwsnoop.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-16s %-18s %2s %-10s %6s %s\n", "TIME(us)",
	    "CLIENT", "OP", "OFFSET(KB)", "BYTES", "PATHNAME");
}

smb:::op-Read-done, smb:::op-ReadX-done
{
	this->dir = "R";
}

smb:::op-Write-done, smb:::op-WriteX-done
{
	this->dir = "W";
}

smb:::op-Read-done, smb:::op-ReadX-done,
smb:::op-Write-done, smb:::op-WriteX-done
{
	printf("%-16d %-18s %2s %-10d %6d %s\n", timestamp / 1000,
	    args[0]->ci_remote, this->dir, args[2]->soa_offset / 1024,
	    args[2]->soa_count, args[1]->soi_curpath);
}
