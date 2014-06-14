#!/usr/sbin/dtrace -Zs
/*
 * sh_calls.d
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
	printf("Tracing... Hit Ctrl-C to end.\n");
}

sh*:::function-entry
{
	@calls[basename(copyinstr(arg0)), "func", copyinstr(arg1)] = count();
}

sh*:::builtin-entry
{
	@calls[basename(copyinstr(arg0)), "builtin", copyinstr(arg1)] = count();
}

sh*:::command-entry
{
	@calls[basename(copyinstr(arg0)), "cmd", copyinstr(arg1)] = count();
}

sh*:::subshell-entry
/arg1 != 0/
{
	@calls[basename(copyinstr(arg0)), "subsh", "-"] = count();
}

dtrace:::END
{
	printf(" %-22s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "COUNT");
	printa(" %-22s %-10s %-32s %@8d\n", @calls);
}
