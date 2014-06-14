#!/usr/sbin/dtrace -s
/*
 * sdretry.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... output every 10 seconds.\n");
}

fbt::sd_set_retry_bp:entry
{
	@[xlate <devinfo_t *>(args[1])->dev_statname,
	    xlate <devinfo_t *>(args[1])->dev_major,
	    xlate <devinfo_t *>(args[1])->dev_minor] = count();
}

tick-10sec
{
	printf("\n%Y:\n", walltimestamp);
	printf("%28s  %-3s,%-4s  %s\n", "DEVICE", "MAJ", "MIN", "RETRIES");
	printa("%28s  %-03d,%-4d  %@d\n", @);
	trunc(@);
}
