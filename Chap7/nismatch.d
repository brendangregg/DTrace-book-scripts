#!/usr/sbin/dtrace -s
/*
 * nismatch.d
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
	printf("%-20s  %-16s %-16s %s\n", "TIME", "DOMAIN", "MAP", "KEY");
}

pid$target::ypset_current_map:entry
{
	self->map = copyinstr(arg0);
	self->domain = copyinstr(arg1);
}

pid$target::finddatum:entry
/self->map != NULL/
{
	printf("%-20Y  %-16s %-16s %S\n", walltimestamp, self->domain,
	    self->map, copyinstr(arg1));
}
