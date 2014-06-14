#!/usr/sbin/dtrace -Cs
/*
 * dnsgetname.d
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

typedef struct dns_name {
	unsigned int			magic;
	unsigned char *			ndata;
	/* truncated */
} dns_name_t;

pid$target::getname:entry
{
	self->arg0 = arg0;
}

pid$target::getname:return
/self->arg0/
{
	this->name = (dns_name_t *)copyin(self->arg0, sizeof (dns_name_t));
	printf("%s\n", copyinstr((uintptr_t)this->name->ndata));
	self->arg0 = 0;
}
