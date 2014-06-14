#!/usr/sbin/dtrace -s
/*
 * bitesize.d
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
	printf("Tracing... Hit Ctrl-C to end.\n");
}

io:::start
{
	this->size = args[0]->b_bcount;
	@Size[pid, curpsinfo->pr_psargs] = quantize(this->size);
}

dtrace:::END
{
	printf("\n%8s  %s\n", "PID", "CMD");
	printa("%8d  %S\n%@d\n", @Size);
}
