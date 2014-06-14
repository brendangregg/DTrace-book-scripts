#!/usr/sbin/dtrace -s
/*
 * ziosnoop.d
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
	start = timestamp;
	printf("%-10s %-3s %-12s %-16s %s\n", "TIME(us)", "CPU",
	    "ZIO_EVENT", "ARG0", "INFO (see script)");
}

fbt::zfs_read:entry,
fbt::zfs_write:entry
{ self->vp = args[0]; }

fbt::zfs_read:return,
fbt::zfs_write:return
{ self->vp = 0; }

fbt::zio_create:return
/$1 || args[1]->io_type/
{
	/* INFO: pool zio_type zio_flag bytes path */
	printf("%-10d %-3d %-12s %-16x %s %d %x %d %s\n",
	    (timestamp - start) / 1000, cpu, "CREATED", arg1,
	    stringof(args[1]->io_spa->spa_name), args[1]->io_type,
	    args[1]->io_flags, args[1]->io_size, self->vp &&
	    self->vp->v_path ? stringof(self->vp->v_path) : "<null>");
}

fbt::zio_*:entry
/$1/
{
	printf("%-10d %-3d %-12s %-16x\n", (timestamp - start) / 1000, cpu,
	    probefunc, arg0);
}

fbt::zio_done:entry
/$1 || args[0]->io_type/
{
	/* INFO: io_error vdev_state vdev_path */
	printf("%-10d %-3d %-12s %-16x %d %d %s\n", (timestamp - start) / 1000,
	    cpu, "DONE", arg0, args[0]->io_error,
	    args[0]->io_vd ? args[0]->io_vd->vdev_state : 0,
	    args[0]->io_vd && args[0]->io_vd->vdev_path ?
	    stringof(args[0]->io_vd->vdev_path) : "<null>");
}
