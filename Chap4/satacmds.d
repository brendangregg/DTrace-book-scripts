#!/usr/sbin/dtrace -Zs
/*
 * satacmds.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

string sata_cmd[uchar_t];

dtrace:::BEGIN
{
	/*
	 * These are from the SATA_DIR_* and SATA_OPMODE_* definitions in
	 * /usr/include/sys/sata/sata_hba.h:
	 */
	sata_dir[1] = "no-data";
	sata_dir[2] = "read";
	sata_dir[4] = "write";
	sata_opmode[0] = "ints+async";	/* interrupts and asynchronous */
	sata_opmode[1] = "poll";	/* polling */
	sata_opmode[4] = "synch";	/* synchronous */
	sata_opmode[5] = "synch+poll";	/* (valid?) */

	/*
	 * These SATA command descriptions were generated from the SATAC_*
	 * definitions in /usr/include/sys/sata/sata_defs.h:
	 */
	sata_cmd[0x90] = "diagnose command";
	sata_cmd[0x10] = "restore cmd, 4 bits step rate";
	sata_cmd[0x50] = "format track command";
	sata_cmd[0xef] = "set features";
	sata_cmd[0xe1] = "idle immediate";
	sata_cmd[0xe0] = "standby immediate";
	sata_cmd[0xde] = "door lock";
	sata_cmd[0xdf] = "door unlock";
	sata_cmd[0xe3] = "idle";
	sata_cmd[0xe2] = "standby";
	sata_cmd[0x08] = "ATAPI device reset";
	sata_cmd[0x92] = "Download microcode";
	sata_cmd[0xed] = "media eject";
	sata_cmd[0xe7] = "flush write-cache";
	sata_cmd[0xec] = "IDENTIFY DEVICE";
	sata_cmd[0xa1] = "ATAPI identify packet device";
	sata_cmd[0x91] = "initialize device parameters";
	sata_cmd[0xa0] = "ATAPI packet";
	sata_cmd[0xc4] = "read multiple w/DMA";
	sata_cmd[0x20] = "read sector";
	sata_cmd[0x40] = "read verify";
	sata_cmd[0xc8] = "read DMA";
	sata_cmd[0x70] = "seek";
	sata_cmd[0xa2] = "queued/overlap service";
	sata_cmd[0xc6] = "set multiple mode";
	sata_cmd[0xca] = "write (multiple) w/DMA";
	sata_cmd[0xc5] = "write multiple";
	sata_cmd[0x30] = "write sector";
	sata_cmd[0x24] = "read sector extended (LBA48)";
	sata_cmd[0x25] = "read DMA extended (LBA48)";
	sata_cmd[0x29] = "read multiple extended (LBA48)";
	sata_cmd[0x34] = "write sector extended (LBA48)";
	sata_cmd[0x35] = "write DMA extended (LBA48)";
	sata_cmd[0x39] = "write multiple extended (LBA48)";
	sata_cmd[0xc7] = "read DMA / may be queued";
	sata_cmd[0x26] = "read DMA ext / may be queued";
	sata_cmd[0xcc] = "write DMA / may be queued";
	sata_cmd[0x36] = "write DMA ext / may be queued";
	sata_cmd[0xe4] = "read port mult reg";
	sata_cmd[0xe8] = "write port mult reg";
	sata_cmd[0x60] = "First-Party-DMA read queued";
	sata_cmd[0x61] = "First-Party-DMA write queued";
	sata_cmd[0x2f] = "read log";
	sata_cmd[0xb0] = "SMART";
	sata_cmd[0xe5] = "check power mode";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

/*
 * Trace SATA command start by probing the entry to the SATA HBA driver.  Four
 * different drivers are covered here; add yours here if it is missing.
 */
fbt::nv_sata_start:entry,
fbt::bcm_sata_start:entry,
fbt::ahci_tran_start:entry,
fbt::mv_start:entry
{
	this->dev = (struct dev_info *)arg0;
	this->sata_pkt = (sata_pkt_t *)arg1;

	this->modname = this->dev != NULL ?
	    stringof(this->dev->devi_node_name) : "<unknown>";
	this->dir =
	    this->sata_pkt->satapkt_cmd.satacmd_flags.sata_data_direction;
	this->dir_text = sata_dir[this->dir] != NULL ?
	    sata_dir[this->dir] : "<none>";
	this->cmd = this->sata_pkt->satapkt_cmd.satacmd_cmd_reg;
	this->cmd_text = sata_cmd[this->cmd] != NULL ?
	    sata_cmd[this->cmd] : lltostr(this->cmd);
	this->op_mode = this->sata_pkt->satapkt_op_mode;
	this->op_text = sata_opmode[this->op_mode] != NULL ?
	    sata_opmode[this->op_mode] : lltostr(this->op_mode);

	@[this->modname, this->dir_text, this->cmd_text, this->op_text] =
	    count();
}

dtrace:::END
{
	printf("  %-14s %-9s %-30s %-10s   %s\n", "DEVICE NODE", "DIR",
	    "COMMAND", "OPMODE", "COUNT");
	printa("  %-14s %-9s %-30s %-10s   %@d\n", @);
}
