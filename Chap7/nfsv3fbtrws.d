#!/usr/sbin/dtrace -s
/*
 * nfsv3fbtrws.d
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
	printf("%-16s %-18s %2s %-10s %6s %s\n", "TIME(us)",
	    "CLIENT", "OP", "OFFSET(KB)", "BYTES", "PATHNAME");
}

fbt::rfs3_read:entry
{
	self->in_rfs3 = 1;
	/* args[0] is READ3args */
	self->offset = args[0]->offset / 1024;
	self->count = args[0]->count;
	self->req = args[3];
	self->dir = "R";
}

fbt::rfs3_write:entry
{
	self->in_rfs3 = 1;
	/* args[0] is WRITE3args */
	self->offset = args[0]->offset / 1024;
	self->count = args[0]->count;
	self->req = args[3];
	self->dir = "W";
}

/* trace nfs3_fhtovp() to retrieve the vnode_t */
fbt::nfs3_fhtovp:return
/self->in_rfs3/
{
	this->vp = args[1];
	this->socket =
	    (struct sockaddr_in *)self->req->rq_xprt->xp_xpc.xpc_rtaddr.buf;
	/* DTrace 1.0: no inet functions, no this->strings */
	this->a = (uint8_t *)&this->socket->sin_addr.S_un.S_addr;
	self->addr1 = strjoin(lltostr(this->a[0] + 0ULL), strjoin(".",
	    strjoin(lltostr(this->a[1] + 0ULL), ".")));
	self->addr2 = strjoin(lltostr(this->a[2] + 0ULL), strjoin(".",
	    lltostr(this->a[3] + 0ULL)));
	self->address = strjoin(self->addr1, self->addr2);

	printf("%-16d %-18s %2s %-10d %6d %s\n", timestamp / 1000,
	    self->address, self->dir, self->offset, self->count,
	    this->vp->v_path != NULL ? stringof(this->vp->v_path) : "<?>");

	self->addr1 = 0;
	self->addr2 = 0;
	self->address = 0;
	self->dir = 0;
	self->req = 0;
	self->offset = 0;
	self->count = 0;
	self->in_rfs3 = 0;
}
