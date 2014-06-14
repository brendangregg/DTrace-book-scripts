#!/usr/sbin/dtrace -s
/*
 * httperrors.d
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
	trace("Tracing HTTP errors... Hit Ctrl-C for report.\n");
}

http*:::request-done
/args[1]->hri_respcode >= 400 && args[1]->hri_respcode < 600/
{
	@[args[0]->ci_remote, args[1]->hri_respcode,
	    args[1]->hri_method, args[1]->hri_uri] = count();
}

dtrace:::END
{
	printf("%8s  %-16s %-4s %-6s %s\n", "COUNT", "CLIENT", "CODE",
	    "METHOD", "URI");
	printa("%@8d  %-16s %-4d %-6s %s\n", @);
}
