#!/usr/sbin/dtrace -Cs
/*
 * icmpsnoop.d
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

#define	IPPROTO_ICMP            1
#define	IPH_HDR_LENGTH(iph)     (((struct ip *)(iph))->ip_hl << 2)

dtrace:::BEGIN
{
	/* See RFC792 and ip_icmp.h */
	icmptype[0] = "ECHOREPLY";
	icmptype[3] = "UNREACH";
	icmpcode[3, 0] = "NET";
	icmpcode[3, 1] = "HOST";
	icmpcode[3, 2] = "PROTOCOL";
	icmpcode[3, 3] = "PORT";
	icmpcode[3, 4] = "NEEDFRAG";
	icmpcode[3, 5] = "SRCFAIL";
	icmpcode[3, 6] = "NET_UNKNOWN";
	icmpcode[3, 7] = "HOST_UNKNOWN";
	icmpcode[3, 8] = "ISOLATED";
	icmpcode[3, 9] = "NET_PROHIB";
	icmpcode[3, 10] = "HOST_PROHIB";
	icmpcode[3, 11] = "TOSNET";
	icmpcode[3, 12] = "TOSHOST";
	icmpcode[3, 13] = "FILTER_PROHIB";
	icmpcode[3, 14] = "HOST_PRECEDENCE";
	icmpcode[3, 15] = "PRECEDENCE_CUTOFF";
	icmptype[4] = "SOURCEQUENCH";
	icmptype[5] = "REDIRECT";
	icmpcode[5, 0] = "NET";
	icmpcode[5, 0] = "HOST";
	icmpcode[5, 0] = "TOSNET";
	icmpcode[5, 0] = "TOSHOST";
	icmptype[8] = "ECHO";
	icmptype[9] = "ROUTERADVERT";
	icmpcode[9, 0] = "COMMON";
	icmpcode[9, 16] = "NOCOMMON";
	icmptype[10] = "ROUTERSOLICIT";
	icmptype[11] = "TIMXCEED";
	icmpcode[11, 0] = "INTRANS";
	icmpcode[11, 1] = "REASS";
	icmptype[12] = "PARAMPROB";
	icmpcode[12, 1] = "OPTABSENT";
	icmpcode[12, 2] = "BADLENGTH";
	icmptype[13] = "TSTAMP";
	icmptype[14] = "TSTAMPREPLY";
	icmptype[15] = "IREQ";
	icmptype[16] = "IREQREPLY";
	icmptype[17] = "MASKREQ";
	icmptype[18] = "MASKREPLY";

	printf("%-20s  %-12s %1s %-15s %-15s %s\n", "TIME", "PROCESS", "D",
	    "REMOTE", "TYPE", "CODE");
}

fbt::icmp_inbound:entry
{
	this->mp = args[1];
	this->ipha = (ipha_t *)this->mp->b_rptr;
	/* stringify manually if inet_ntoa() unavailable */
	this->addr = inet_ntoa(&this->ipha->ipha_src);
	this->dir = "<";
}

fbt::ip_xmit_v4:entry
/arg4 && args[4]->conn_ulp == IPPROTO_ICMP/
{
	this->mp = args[0];
	this->ipha = (ipha_t *)this->mp->b_rptr;
	/* stringify manually if inet_ntoa() unavailable */
	this->addr = inet_ntoa(&this->ipha->ipha_dst);
	this->dir = ">";
}

fbt::icmp_inbound:entry,
fbt::ip_xmit_v4:entry
/this->dir != NULL/
{
	this->iph_hdr_length = IPH_HDR_LENGTH(this->ipha);
	this->icmph = (icmph_t *)&this->mp->b_rptr[(char)this->iph_hdr_length];
	this->type = this->icmph->icmph_type;
	this->code = this->icmph->icmph_code;
	this->typestr = icmptype[this->type] != NULL ?
	    icmptype[this->type] : lltostr(this->type);
	this->codestr = icmpcode[this->type, this->code] != NULL ?
	    icmpcode[this->type, this->code] : lltostr(this->code);

	printf("%-20Y  %-12.12s %1s %-15s %-15s %s\n", walltimestamp, execname,
	    this->dir, this->addr, this->typestr, this->codestr);
}
