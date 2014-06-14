#!/usr/sbin/dtrace -Zs
/*
 * ftpdxfer.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
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
	printf("%-20s %-8s %9s %-5s %-6s %s\n", "CLIENT", "USER", "LAT(us)",
	    "DIR", "BYTES", "PATH");
}

ftp*:::transfer-start
{
	self->start = timestamp;
}

ftp*:::transfer-done
/self->start/
{
	this->delta = (timestamp - self->start) / 1000;
	printf("%-20s %-8s %9d %-5s %-6d %s\n", args[0]->ci_remote,
	    args[1]->fti_user, this->delta, args[1]->fti_cmd,
	    args[1]->fti_nbytes, args[1]->fti_pathname);
	self->start = 0;
}
