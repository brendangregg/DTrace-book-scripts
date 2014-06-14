#!/usr/sbin/dtrace -qs
/*
 * scpwatcher.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

inline int stdout = 1;

syscall::write:entry
/execname == "scp" && arg0 == stdout/
{
	printf("%s\n", copyinstr(arg1));
}
