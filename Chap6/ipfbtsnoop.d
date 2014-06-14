#!/usr/sbin/dtrace -Cs
/*
 * ipfbtsnoop.d
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

#define	ETHERTYPE_IP            (0x0800)        /* IP protocol */
#define	ETHERTYPE_IPV6          (0x86dd)        /* IPv6 */

#define	IPPROTO_IP              0
#define	IPPROTO_ICMP            1
#define	IPPROTO_IGMP            2
#define	IPPROTO_TCP             6
#define	IPPROTO_UDP             17

#define	DL_ETHER                0x4

#define	IPH_HDR_VERSION(ipha) \
	((int)(((ipha_t *)ipha)->ipha_version_and_hdr_length) >> 4)

/* stringify an IPv4 address without inet*() being available */
#define	IPV4_ADDR_TO_STR(string, addr)                                  \
	this->a = (uint8_t *)&addr;                                     \
	this->addr1 = strjoin(lltostr(this->a[0] + 0ULL), strjoin(".",  \
	    strjoin(lltostr(this->a[1] + 0ULL), ".")));                 \
	this->addr2 = strjoin(lltostr(this->a[2] + 0ULL), strjoin(".",  \
	    lltostr(this->a[3] + 0ULL)));                               \
	string = strjoin(this->addr1, this->addr2);

/* convert net to host byte order for little-endian systems  */
#define	BSWAP_16(host, net)                                             \
	host = (net & 0xFF00) >> 8;                                     \
	host |= (net & 0xFF) << 8;

dtrace:::BEGIN
{
	/* selected protocols; see /usr/include/netinet/in.h for full list */
	ipproto[IPPROTO_IP] = "IP";
	ipproto[IPPROTO_ICMP] = "ICMP";
	ipproto[IPPROTO_IGMP] = "IGMP";
	ipproto[IPPROTO_TCP] = "TCP";
	ipproto[IPPROTO_UDP] = "UDP";

	printf("%-15s %-8s %-8s %-15s   %-15s %5s %5s\n", "TIME(us)",
	    "ONCPU", "INT", "SOURCE", "DEST", "BYTES", "PROTO");
}

fbt::ip_input:entry
{
	this->mp = args[2];
	this->ill = args[0];
	this->ipha = (ipha_t *)this->mp->b_rptr;
	this->name = stringof(this->ill->ill_name);
	this->ok = 1;
}

/* rewrite for dls_tx() on older Solaris kernels */
fbt::mac_tx:entry
{
	this->mc = (mac_client_impl_t *)args[0];
}

/* filter out non-Ethernet calls */
fbt::mac_tx:entry
/this->mc->mci_mip->mi_info.mi_nativemedia == DL_ETHER/
{
	this->mp = args[1];
	this->eth = (struct ether_header *)this->mp->b_rptr;
	this->type = this->eth->ether_type;
}

/* filter out non-IP calls */
fbt::mac_tx:entry
/this->type == ETHERTYPE_IP || this->type == ETHERTYPE_IPV6/
{
	this->ipha = (ipha_t *)&this->mp->b_rptr[sizeof (struct ether_header)];
	this->name = this->mc->mci_name;
	this->ok = 1;
}

fbt::ip_input:entry, fbt::mac_tx:entry
/this->ok && IPH_HDR_VERSION(this->ipha) == 4/
{
	BSWAP_16(this->pktlen, this->ipha->ipha_length);
	IPV4_ADDR_TO_STR(this->src, this->ipha->ipha_src);
	IPV4_ADDR_TO_STR(this->dst, this->ipha->ipha_dst);

	this->proto = ipproto[this->ipha->ipha_protocol] != NULL ?
	    ipproto[this->ipha->ipha_protocol] :
	    lltostr(this->ipha->ipha_protocol);

	printf("%-15d %-8.8s %-8.8s %-15s > %-15s %5d %5s\n",
	    timestamp / 1000, execname, this->name, this->src, this->dst,
	    this->pktlen, this->proto);
}
