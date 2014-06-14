#!/usr/sbin/dtrace -s
/*
 * solvfssnoop.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-12s %6s %6s %-12.12s %-12s %-4s %s\n", "TIME(ms)", "UID",
	    "PID", "PROCESS", "CALL", "KB", "PATH");
}

/* see /usr/include/sys/vnode.h */

fbt::fop_read:entry, fbt::fop_write:entry
{
	self->path = args[0]->v_path;
	self->kb = args[1]->uio_resid / 1024;
}

fbt::fop_open:entry
{
	self->path = (*args[0])->v_path;
	self->kb = 0;
}

fbt::fop_close:entry, fbt::fop_ioctl:entry, fbt::fop_getattr:entry,
fbt::fop_readdir:entry
{
	self->path = args[0]->v_path;
	self->kb = 0;
}

fbt::fop_read:entry, fbt::fop_write:entry, fbt::fop_open:entry,
fbt::fop_close:entry, fbt::fop_ioctl:entry, fbt::fop_getattr:entry,
fbt::fop_readdir:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
	printf("%-12d %6d %6d %-12.12s %-12s %-4d %s\n", timestamp / 1000000,
	    uid, pid, execname, probefunc, self->kb,
	    self->path != NULL ? stringof(self->path) : "<null>");
}

fbt::fop_read:entry, fbt::fop_write:entry, fbt::fop_open:entry,
fbt::fop_close:entry, fbt::fop_ioctl:entry, fbt::fop_getattr:entry,
fbt::fop_readdir:entry
{
	self->path = 0; self->kb = 0;
}
