#!/usr/sbin/dtrace -s
/*
 * tmpusers.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("%6s %6s %-16s %s\n", "UID", "PID", "PROCESS", "FILE");
}

fbt::tmp_open:entry
{
	printf("%6d %6d %-16s %s\n", uid, pid, execname,
	    stringof((*args[0])->v_path));
}
