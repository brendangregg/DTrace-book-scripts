#!/usr/sbin/dtrace -s
/*
 * cifsfbtnofile.d
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
	/* a few likely codes are included from ntstatus.h */
	ntstatus[0] = "SUCCESS";
	ntstatus[1] = "UNSUCCESSFUL";
	ntstatus[15] = "NO_SUCH_FILE";
	ntstatus[186] = "FILE_IS_A_DIR";

	printf(" %-16s %3s %-13s %s\n", "CLIENT", "ERR", "ERROR", "PATHNAME");
}

fbt::smb*find_first*:entry  { self->in_find_first = 1; }
fbt::smb*find_first*:return { self->in_find_first = 0; }

/* assume smb_odir_open() checks relevant path during find_entries */
fbt::smb_odir_open:entry
/self->in_find_first/
{
	self->sr = args[0];
	self->path = args[1];
}

/* assume smbsr_set_error() will set relevant error during find_entries */
fbt::smbsr_set_error:entry
/self->in_find_first/
{
	self->err = args[1]->status;
}

/* if an error was previously seen during find_entries, print cached details */
fbt::smb*find_entries:return
/self->sr && self->err/
{
	this->str = ntstatus[self->err] != NULL ? ntstatus[self->err] : "?";
	this->remote = self->sr->session->ipaddr.a_family == AF_INET ?
	    inet_ntoa(&self->sr->session->ipaddr.au_addr.au_ipv4) :
	inet_ntoa6(&self->sr->session->ipaddr.au_addr.au_ipv6);
	printf(" %-16s %3d %-13s %s%s\n", this->remote, self->err, this->str,
	    self->sr->tid_tree->t_sharename, stringof(self->path));
}

fbt::smb*find_entries:return
/self->sr/
{
	self->sr = 0; self->path = 0; self->err = 0;
}
