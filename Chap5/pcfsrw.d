#!/usr/sbin/dtrace -s
/*
 * pcfsrw.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-20s %1s %4s %6s %3s %s\n", "TIME", "D", "KB",
	    "ms", "ERR", "PATH");
}

fbt::pcfs_read:entry,
fbt::pcfs_write:entry,
fbt::pcfs_readdir:entry
{
	self->path = args[0]->v_path;
	self->kb = args[1]->uio_resid / 1024;
	self->start = timestamp;
}

fbt::pcfs_read:return,
fbt::pcfs_write:return,
fbt::pcfs_readdir:return
/self->start/
{
	this->iotime = (timestamp - self->start) / 1000000;
	this->dir = probefunc == "pcfs_read" ? "R" : "W";
	printf("%-20Y %1s %4d %6d %3d %s\n", walltimestamp,
	    this->dir, self->kb, this->iotime, arg1,
	    self->path != NULL ? stringof(self->path) : "<null>");
	self->start = 0; self->path = 0; self->kb = 0;
}
