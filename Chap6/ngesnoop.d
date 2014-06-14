#!/usr/sbin/dtrace -s
/*
 * ngesnoop.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
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
	printf("%-15s  %-8s %-2s %-17s  %-17s  %-5s %5s\n", "TIME(us)",
	    "INT", "D", "SOURCE", "DEST", "PROTO", "BYTES");
}

fbt::nge_recv_ring:entry
{
	self->ngep = args[0];
}

fbt::mac_rx:entry
/self->ngep/
{
	this->mp = args[2];
	this->nge = self->ngep;
	this->dir = "<-";
	self->ngep = 0;
}

fbt::nge_send:entry
{
	this->nge = (nge_t *)arg0;
	this->mp = args[1];
	this->dir = "->";
}

fbt::mac_rx:entry,
fbt::nge_send:entry
/this->mp/
{
	this->eth = (struct ether_header *)this->mp->b_rptr;
	this->s = (char *)&this->eth->ether_shost;
	this->d = (char *)&this->eth->ether_dhost;
	this->t = ntohs(this->eth->ether_type);
	printf("%-15d  %-8s %2s ", timestamp / 1000, this->nge->ifname,
	    this->dir);
	printf("%02x:%02x:%02x:%02x:%02x:%02x  ", this->s[0], this->s[1],
	    this->s[2], this->s[3], this->s[4], this->s[5]);
	printf("%02x:%02x:%02x:%02x:%02x:%02x  ", this->d[0], this->d[1],
	    this->d[2], this->d[3], this->d[4], this->d[5]);
	printf(" %-04x %5d\n", this->t, msgdsize(this->mp));
}
