#!/usr/sbin/dtrace -s
/*
 * perturbation.d
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

dtrace:::BEGIN
{
	printf("Tracing ZFS perturbation by %s()... Ctrl-C to end.\n", $$1);
}

fbt::$$1:entry
{
	self->pstart = timestamp;
	perturbation = 1;
}

fbt::$$1:return
/self->pstart/
{
	this->ptime = (timestamp - self->pstart) / 1000000;
	@[probefunc, "perturbation duration (ms)"] = quantize(this->ptime);
	perturbation = 0;
}

fbt::zfs_read:entry,
fbt::zfs_write:entry
{
	self->start = timestamp;
}

fbt::zfs_read:return,
fbt::zfs_write:return
/self->start/
{
	this->iotime = (timestamp - self->start) / 1000000;
	@[probefunc, perturbation ? "during perturbation (ms)" :
	    "normal (ms)"] = quantize(this->iotime);
	self->start = 0;
}
