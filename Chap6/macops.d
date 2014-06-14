#!/usr/sbin/dtrace -s
/*
 * macops.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	/* See /usr/include/sys/dlpi.h */
	mediatype[0x0] = "CSMACD";
	mediatype[0x1] = "TPB";
	mediatype[0x2] = "TPR";
	mediatype[0x3] = "METRO";
	mediatype[0x4] = "ETHER";
	mediatype[0x05] = "HDLC";
	mediatype[0x06] = "CHAR";
	mediatype[0x07] = "CTCA";
	mediatype[0x08] = "FDDI";
	mediatype[0x10] = "FC";
	mediatype[0x11] = "ATM";
	mediatype[0x12] = "IPATM";
	mediatype[0x13] = "X25";
	mediatype[0x14] = "ISDN";
	mediatype[0x15] = "HIPPI";
	mediatype[0x16] = "100VG";
	mediatype[0x17] = "100VGTPR";
	mediatype[0x18] = "ETH_CSMA";
	mediatype[0x19] = "100BT";
	mediatype[0x1a] = "IB";
	mediatype[0x0a] = "FRAME";
	mediatype[0x0b] = "MPFRAME";
	mediatype[0x0c] = "ASYNC";
	mediatype[0x0d] = "IPX25";
	mediatype[0x0e] = "LOOP";
	mediatype[0x09] = "OTHER";

	printf("Tracing MAC calls... Hit Ctrl-C to end.\n");
}

/* the following are not complete lists of mac functions; add as needed */

/* mac functions with mac_client_impl_t as the first arg */
fbt::mac_promisc_add:entry,
fbt::mac_promisc_remove:entry,
fbt::mac_multicast_add:entry,
fbt::mac_multicast_remove:entry,
fbt::mac_unicast_add:entry,
fbt::mac_unicast_remove:entry,
fbt::mac_tx:entry
{
	this->macp = (mac_client_impl_t *)arg0;
	this->name = stringof(this->macp->mci_name);
	this->media = this->macp->mci_mip->mi_info.mi_media;
	this->type = mediatype[this->media] != NULL ?
	    mediatype[this->media] : lltostr(this->media);
	this->dir = probefunc == "mac_tx" ? "->" : ".";
	@[this->name, this->type, probefunc, this->dir] = count();
}

/* mac functions with mac_impl_t as the first arg */
fbt::mac_stop:entry,
fbt::mac_start:entry,
fbt::mac_stat_get:entry,
fbt::mac_ioctl:entry,
fbt::mac_capab_get:entry,
fbt::mac_set_prop:entry,
fbt::mac_get_prop:entry,
fbt::mac_rx:entry
{
	this->mip = (mac_impl_t *)arg0;
	this->name = stringof(this->mip->mi_name);
	this->media = this->mip->mi_info.mi_media;
	this->type = mediatype[this->media] != NULL ?
	    mediatype[this->media] : lltostr(this->media);
	this->dir = probefunc == "mac_rx" ? "<-" : ".";
	@[this->name, this->type, probefunc, this->dir] = count();
}

dtrace:::END
{
	printf("  %-16s %-16s %-16s %-4s %14s\n", "INT", "MEDIA", "MAC",
	    "DATA", "CALLS");
	printa("  %-16s %-16s %-16s %-4s %@14d\n", @);
}
