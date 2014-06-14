#!/usr/sbin/dtrace -s
/*
 * sysdispqlen.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Sampling at 1001 Hertz... Hit Ctrl-C to end.\n");
}

profile:::profile-1001hz
{
	@["System wide disp queue length:"] =
	    sum(curthread->t_cpu->cpu_disp->disp_nrunnable);
}

profile:::tick-1sec
{
	normalize(@, 1001);
	printa(@);
	trunc(@);
}
