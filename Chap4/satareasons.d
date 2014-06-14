#!/usr/sbin/dtrace -s
/*
 * satareasons.d
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
	 * These are SATA_DIR_* from /usr/include/sys/sata/sata_hba.h:
	 */
	sata_dir[1] = "no-data";
	sata_dir[2] = "read";
	sata_dir[4] = "write";

	/*
	 * Some SATAC_* definitions from /usr/include/sys/sata/sata_defs.h, for
	 * commands commonly issued.  More can be added from satacmds.d.
	 */
	sata_cmd[0x20] = "read sector";
	sata_cmd[0x25] = "read DMA extended";
	sata_cmd[0x35] = "write DMA extended";
	sata_cmd[0x30] = "write sector";
	sata_cmd[0x40] = "read verify";
	sata_cmd[0x70] = "seek";
	sata_cmd[0x90] = "diagnose command";
	sata_cmd[0xb0] = "SMART";
	sata_cmd[0xec] = "IDENTIFY DEVICE";
	sata_cmd[0xe5] = "check power mode";
	sata_cmd[0xe7] = "flush write-cache";
	sata_cmd[0xef] = "set features";

	/*
	 * These are SATA_PKT_* from /usr/include/sys/sata/sata_hba.h:
	 */
	sata_reason[-1] = "Not completed, busy";
	sata_reason[0] = "Success";
	sata_reason[1] = "Device reported error";
	sata_reason[2] = "Not accepted, queue full";
	sata_reason[3] = "Not completed, port error";
	sata_reason[4] = "Cmd unsupported";
	sata_reason[5] = "Aborted by request";
	sata_reason[6] = "Operation timeout";
	sata_reason[7] = "Aborted by reset request";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

fbt::sd_start_cmds:entry
{
	/* see the sd_start_cmds() source to understand the following logic */
	self->bp = args[1] != NULL ? args[1] : args[0]->un_waitq_headp;
}

fbt::sd_start_cmds:return { self->bp = 0; }

fbt::sata_hba_start:entry
/self->bp->b_dip/
{
	statname[args[0]->txlt_sata_pkt] =
	    xlate <devinfo_t *>(self->bp)->dev_statname;
}

fbt::sata_pkt_free:entry
/args[0]->txlt_sata_pkt->satapkt_cmd.satacmd_cmd_reg/
{
	this->sata_pkt = args[0]->txlt_sata_pkt;
	this->devname = statname[this->sata_pkt] != NULL ?
	    statname[this->sata_pkt] : "<?>";
	this->dir =
	    this->sata_pkt->satapkt_cmd.satacmd_flags.sata_data_direction;
	this->dir_text = sata_dir[this->dir] != NULL ?
	    sata_dir[this->dir] : "<none>";
	this->cmd = this->sata_pkt->satapkt_cmd.satacmd_cmd_reg;
	this->cmd_text = sata_cmd[this->cmd] != NULL ?
	    sata_cmd[this->cmd] : lltostr(this->cmd);
	this->reason = this->sata_pkt->satapkt_reason;
	this->reason_text = sata_reason[this->reason] != NULL ?
	    sata_reason[this->reason] : lltostr(this->reason);
	statname[this->sata_pkt] = 0;

	@[this->devname, this->dir_text, this->cmd_text, this->reason_text] =
	    count();
}

dtrace:::END
{
	printf("  %-8s %-10s %-20s %25s  %s\n", "DEVICE", "DIR", "COMMAND",
	    "REASON", "COUNT");
	printa("  %-8s %-10s %-20s %25s  %@d\n", @);
}
