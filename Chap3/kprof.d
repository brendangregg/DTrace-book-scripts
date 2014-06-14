#!/usr/sbin/dtrace -s
/*
 * kprof.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

profile-997hz
/arg0 && curthread->t_pri != -1/
{
	@[stack()] = count();
}
tick-10sec
{
	trunc(@, 10);
	printa(@);
	exit(0);
}
