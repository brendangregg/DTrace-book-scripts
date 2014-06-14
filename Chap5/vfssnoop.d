#!/usr/sbin/dtrace -s
/*
 * vfssnoop.d
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
#pragma D option dynvarsize=4m

dtrace:::BEGIN
{
	printf("%-12s %6s %6s %-12.12s %-12s %-4s %s\n", "TIME(ms)", "UID",
	    "PID", "PROCESS", "CALL", "KB", "PATH/FILE");
}

/*
 * Populate Vnode2Path from namecache hits
 */
vfs:namecache:lookup:hit
/V2P[arg2] == NULL/
{
	V2P[arg2] = stringof(arg1);
}

/*
 * (Re)populate Vnode2Path from successful namei() lookups
 */
vfs:namei:lookup:entry
{
	self->buf = arg1;
}
vfs:namei:lookup:return
/self->buf != NULL && arg0 == 0/
{
	V2P[arg1] = stringof(self->buf);
}
vfs:namei:lookup:return
{
	self->buf = 0;
}

/*
 * Trace and print VFS calls
 */
vfs::vop_read:entry, vfs::vop_write:entry
{
	self->path = V2P[arg0];
	self->kb = args[1]->a_uio->uio_resid / 1024;
}

vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_ioctl:entry,
vfs::vop_getattr:entry, vfs::vop_readdir:entry
{
	self->path = V2P[arg0];
	self->kb = 0;
}

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_open:entry,
vfs::vop_close:entry, vfs::vop_ioctl:entry, vfs::vop_getattr:entry,
vfs::vop_readdir:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
	printf("%-12d %6d %6d %-12.12s %-12s %-4d %s\n", timestamp / 1000000,
	    uid, pid, execname, probefunc, self->kb,
	self->path != NULL ? self->path : "<unknown>");
}

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_open:entry,
vfs::vop_close:entry, vfs::vop_ioctl:entry, vfs::vop_getattr:entry,
vfs::vop_readdir:entry
{
	self->path = 0; self->kb = 0;
}

/*
 * Tidy V2P, otherwise it gets too big (dynvardrops)
 */
vfs:namecache:purge:done,
vfs::vop_close:entry
{
	V2P[arg0] = 0;
}
