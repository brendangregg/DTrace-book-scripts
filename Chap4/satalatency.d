#!/usr/sbin/dtrace -Zs
/*
 * satalatency.d
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

	/*
	 * Trace SATA command start by probing the entry to the SATA HBA
	 * driver.  Four different drivers are covered here; add yours here
	 * if it is missing.
	 */
fbt::nv_sata_start:entry,
fbt::bcm_sata_start:entry,
fbt::ahci_tran_start:entry,
fbt::mv_start:entry
{
	start[arg1] = timestamp;
}

fbt::sata_pkt_free:entry
/start[(uint64_t)args[0]->txlt_sata_pkt]/
{
	this->sata_pkt = args[0]->txlt_sata_pkt;
	this->delta = (timestamp - start[(uint64_t)this->sata_pkt]) / 1000;
	this->cmd = this->sata_pkt->satapkt_cmd.satacmd_cmd_reg;
	this->cmd_text = sata_cmd[this->cmd] != NULL ?
	    sata_cmd[this->cmd] : lltostr(this->cmd);
	this->reason = this->sata_pkt->satapkt_reason;
	this->reason_text = sata_reason[this->reason] != NULL ?
	    sata_reason[this->reason] : lltostr(this->reason);

	@num[this->cmd_text, this->reason_text] = count();
	@average[this->cmd_text, this->reason_text] = avg(this->delta);
	@total[this->cmd_text, this->reason_text] = sum(this->delta);

	start[(uint64_t)this->sata_pkt] = 0;
}

dtrace:::END
{
	normalize(@total, 1000);
	printf("\n  %-18s %23s %10s %10s %10s\n", "SATA COMMAND",
	    "COMPLETION", "COUNT", "AVG(us)", "TOTAL(ms)");
	printa("  %-18s %23s %@10d %@10d %@10d\n", @num, @average, @total);
}
