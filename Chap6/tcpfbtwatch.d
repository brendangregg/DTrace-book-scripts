#!/usr/sbin/dtrace -Cs
/*
 * tcpfbtwatch.d
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

#define	IPH_HDR_VERSION(ipha) \
	((int)(((ipha_t *)ipha)->ipha_version_and_hdr_length) >> 4)

#define	TCPS_SYN_RCVD   -1

#define	conn_tcp        conn_proto_priv.cp_tcp
#define	conn_lport      u_port.tcpu_ports.tcpu_lport

dtrace:::BEGIN
{
	printf("%-20s  %-24s %-24s %6s\n", "TIME", "REMOTE", "LOCAL", "LPORT");
}

fbt::tcp_rput_data:entry
{
	self->connp = (conn_t *)arg0;
	self->tcp = self->connp->conn_tcp;
	self->mp = args[1];
	self->ipha = (ipha_t *)self->mp->b_rptr;
	self->in_tcp_rput_data = 1;
}

fbt::tcp_rput_data:entry
/self->tcp->tcp_state == TCPS_SYN_RCVD && IPH_HDR_VERSION(self->ipha) == 4/
{
	this->src = inet_ntoa(&self->ipha->ipha_src);
	this->dst = inet_ntoa(&self->ipha->ipha_dst);
	this->lport = ntohs(self->connp->conn_lport);
	printf("%-20Y  %-24s %-24s %6d\n", walltimestamp, this->src,
	    this->dst, this->lport);
}

fbt::tcp_find_pktinfo:return
/self->in_tcp_rput_data && self->tcp->tcp_state == TCPS_SYN_RCVD &&
	IPH_HDR_VERSION(self->ipha) == 6/
{
	this->mp = args[1];
	this->ip6h = (struct ip6_hdr *)this->mp->b_rptr;
	this->src = inet_ntoa6(&this->ip6h->ip6_src);
	this->dst = inet_ntoa6(&this->ip6h->ip6_dst);
	this->lport = ntohs(self->connp->conn_lport);
	printf("%-20Y  %-24s %-24s %6d\n", walltimestamp, this->src,
	    this->dst, this->lport);
}

fbt::tcp_rput_data:return
{
	self->connp = 0; self->tcp = 0; self->mp = 0;
	self->ipha = 0; self->in_tcp_rput_data = 0;
}
