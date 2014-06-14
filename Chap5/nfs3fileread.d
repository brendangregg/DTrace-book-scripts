#!/usr/sbin/dtrace -s
/*
 * nfs3fileread.d
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
	trace("Tracing NFSv3 client file reads... Hit Ctrl-C to end.\n");
}

fbt::nfs3_read:entry
{
	this->path = args[0]->v_path;
	this->bytes = args[1]->uio_resid;
	@r[this->path ? stringof(this->path) : "<null>"] = sum(this->bytes);
}

fbt::nfs3_directio_read:entry
{
	this->path = args[0]->v_path;
	this->bytes = args[1]->uio_resid;
	@n[this->path ? stringof(this->path) : "<null>"] = sum(this->bytes);
}

fbt::nfs3_getpage:entry
{
	this->path = args[0]->v_path;
	this->bytes = arg2;
	@n[this->path ? stringof(this->path) : "<null>"] = sum(this->bytes);
}

dtrace:::END
{
	printf(" %-56s %10s %10s\n", "FILE", "READ(B)", "NET(B)");
	printa(" %-56s %@10d %@10d\n", @r, @n);
}
