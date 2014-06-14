#!/usr/sbin/dtrace -s
/*
 * cifsfileio.d
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
	trace("Tracing... Hit Ctrl-C to end.\n");
}

smb:::op-Read-done, smb:::op-ReadX-done
{
	@readbytes[args[1]->soi_curpath] = sum(args[2]->soa_count);
}

smb:::op-Write-done, smb:::op-WriteX-done
{
	@writebytes[args[1]->soi_curpath] = sum(args[2]->soa_count);
}

dtrace:::END
{
	printf("\n%12s %12s  %s\n", "Rbytes", "Wbytes", "Pathname");
	printa("%@12d %@12d  %s\n", @readbytes, @writebytes);
}
