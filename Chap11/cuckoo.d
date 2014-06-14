#!/usr/sbin/dtrace -s
/*
 * cuckoo.d
 *
 * Example script from Chapter 11 of the book: DTrace: Dynamic Tracing in
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
	printf("%-20s %6s %6s %6s %s\n", "TIME", "PID", "PPID", "UID", "TEXT");
}

fbt::cnwrite:entry
{
	this->iov = args[1]->uio_iov;
	this->len = this->iov->iov_len;
	this->text = stringof((char *)copyin((uintptr_t)this->iov->iov_base,
	    this->len));
	this->text[this->len] = '\0';

	printf("%-20Y %6d %6d %6d %s\n", walltimestamp, pid, ppid, uid,
	    this->text);
}
