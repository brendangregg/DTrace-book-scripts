#!/usr/sbin/dtrace -s
/*
 * pf.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN { trace("Tracing...Ouput after 10 seconds, or Ctrl-C\n"); }

fbt:unix:pagefault:entry
{
	@st[execname] = count();
	self->pfst = timestamp
}
fbt:unix:pagefault:return
/self->pfst/
{
	@pft[execname] = sum(timestamp - self->pfst);
	self->pfst = 0;
}
tick-10s
{
	printf("Pagefault counts by execname ...\n");
	printa(@st);

	printf("\nPagefault times(ns) by execname...\n");
	printa(@pft);

	trunc(@st);
	trunc(@pft);
}
