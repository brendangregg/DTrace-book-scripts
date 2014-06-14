#!/usr/sbin/dtrace -Zs
/*
 * rb_calls.d
 *
 * Example script from Chapter 8 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing Ruby... Hit Ctrl-C to end.\n");
}

ruby*:::function-entry
{
	@funcs[pid, basename(copyinstr(arg2)), copyinstr(arg0),
	    copyinstr(arg1)] = count();
}

dtrace:::END
{
	printf("%-6s %-28.28s %-16s %-16s %8s\n", "PID", "FILE", "CLASS",
	    "METHOD", "CALLS");
	printa("%-6d %-28.28s %-16s %-16s %@8d\n", @funcs);
}
