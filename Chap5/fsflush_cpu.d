#!/usr/sbin/dtrace -s
/*
 * fsflush_cpu.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	trace("Tracing fsflush...\n");
	@fopbytes = sum(0); @iobytes = sum(0);
}

fbt::fsflush_do_pages:entry
{
	self->vstart = vtimestamp;
}

fbt::fop_putpage:entry
/self->vstart/
{
	@fopbytes = sum(arg2);
}

io:::start
/self->vstart/
{
	@iobytes = sum(args[0]->b_bcount);
	@ionum = count();
}

fbt::fsflush_do_pages:return
/self->vstart/
{
	normalize(@fopbytes, 1024);
	normalize(@iobytes, 1024);
	this->delta = (vtimestamp - self->vstart) / 1000000;
	printf("%Y %4d ms, ", walltimestamp, this->delta);
	printa("fop: %7@d KB, ", @fopbytes);
	printa("device: %7@d KB ", @iobytes);
	printa("%5@d I/O", @ionum);
	printf("\n");
	self->vstart = 0;
	clear(@fopbytes); clear(@iobytes); clear(@ionum);
}
