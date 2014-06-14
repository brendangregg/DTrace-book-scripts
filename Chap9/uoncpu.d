#!/usr/sbin/dtrace -s
/*
 * uoncpu.d
 *
 * Example script from Chapter 9 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

profile:::profile-1001
/execname == $$1/
{
	@["\n  on-cpu (count @1001hz):", ustack()] = count();
}
