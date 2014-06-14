#!/usr/sbin/dtrace -Cs
/*
 * mmap.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#include <sys/mman.h>

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%6s %-12s %-4s %-8s %-8s %-8s %s\n", "PID",
	    "PROCESS", "PROT", "FLAGS", "OFFS(KB)", "SIZE(KB)", "PATH");
}

syscall::mmap*:entry
/fds[arg4].fi_pathname != "<none>"/
{
	/* see mmap(2) and /usr/include/sys/mman.h */
	printf("%6d %-12.12s %s%s%s  %s%s%s%s%s%s%s%s %-8d %-8d %s\n",
	    pid, execname,
	    arg2 & PROT_EXEC  ? "E" : "-",	/* pages can be executed */
	    arg2 & PROT_WRITE ? "W" : "-",	/* pages can be written */
	    arg2 & PROT_READ  ? "R" : "-",	/* pages can be read */
	    arg3 & MAP_INITDATA  ? "I" : "-",	/* map data segment */
	    arg3 & MAP_TEXT      ? "T" : "-",	/* map code segment */
	    arg3 & MAP_ALIGN     ? "L" : "-",	/* addr specifies alignment */
	    arg3 & MAP_ANON      ? "A" : "-",	/* map anon pages directly */
	    arg3 & MAP_NORESERVE ? "N" : "-",	/* don't reserve swap area */
	    arg3 & MAP_FIXED     ? "F" : "-",	/* user assigns address */
	    arg3 & MAP_PRIVATE   ? "P" : "-",	/* changes are private */
	    arg3 & MAP_SHARED    ? "S" : "-",	/* share changes */
	    arg5 / 1024, arg1 / 1024, fds[arg4].fi_pathname);
}
