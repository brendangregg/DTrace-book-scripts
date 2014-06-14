#!/usr/sbin/dtrace -Cs
/*
 * nosnoopforyou.d
 *
 * Example script from Chapter 11 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option destructive

/* /usr/include/sys/dlpi.h: */
#define	DL_PROMISCON_REQ	0x1f

dtrace:::BEGIN
{
	trace("Preventing promiscuity...\n");
}

fbt::dld_wput_nondata:entry
{
	this->mp = args[1];
	this->prim = ((union DL_primitives *)this->mp->b_rptr)->dl_primitive;
}

fbt::dld_wput_nondata:entry
/this->prim == DL_PROMISCON_REQ/
{
	printf("%Y KILLED %s PID:%d PPID:%d\n", walltimestamp, execname,
	    pid, ppid);
	/* raise(9); */
}
