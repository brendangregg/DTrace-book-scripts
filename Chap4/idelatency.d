#!/usr/sbin/dtrace -s
/*
 * idelatency.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

string dcmd[uchar_t];

dtrace:::BEGIN
{
	/*
	 * These command descriptions are from the DCMD_* definitions
	 * in /usr/include/sys/dktp/dadkio.h:
	 */
	dcmd[1] = "Read Sectors/Blocks";
	dcmd[2] = "Write Sectors/Blocks";
	dcmd[3] = "Format Tracks";
	dcmd[4] = "Format entire drive";
	dcmd[5] = "Recalibrate";
	dcmd[6] = "Seek to Cylinder";
	dcmd[7] = "Read Verify sectors on disk";
	dcmd[8] = "Read manufacturers defect list";
	dcmd[9] = "Lock door";
	dcmd[10] = "Unlock door";
	dcmd[11] = "Start motor";
	dcmd[12] = "Stop motor";
	dcmd[13] = "Eject medium";
	dcmd[14] = "Update geometry";
	dcmd[15] = "Get removable disk status";
	dcmd[16] = "cdrom pause";
	dcmd[17] = "cdrom resume";
	dcmd[18] = "cdrom play by track and index";
	dcmd[19] = "cdrom play msf";
	dcmd[20] = "cdrom sub channel";
	dcmd[21] = "cdrom read mode 1";
	dcmd[22] = "cdrom read table of contents header";
	dcmd[23] = "cdrom read table of contents entry";
	dcmd[24] = "cdrom read offset";
	dcmd[25] = "cdrom mode 2";
	dcmd[26] = "cdrom volume control";
	dcmd[27] = "flush write cache to physical medium";

	/* from CPS_* definitions in /usr/include/sys/dktp/cmpkt.h */
	reason[0] = "success";
	reason[1] = "failure";
	reason[2] = "fail+err";
	reason[3] = "aborted";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

/* IDE command start */
fbt::dadk_pktprep:return
{
	start[arg1] = timestamp;
}

/* IDE command completion */
fbt::dadk_pktcb:entry
/start[arg0]/
{
	this->pktp = args[0];

	this->delta = (timestamp - start[arg0]) / 1000;
	this->cmd = *((uchar_t *)this->pktp->cp_cdbp);
	this->cmd_text = dcmd[this->cmd] != NULL ?
	    dcmd[this->cmd] : lltostr(this->cmd);
	this->reason = this->pktp->cp_reason;
	this->reason_text = reason[this->reason] != NULL ?
	    reason[this->reason] : lltostr(this->reason);

	@num[this->cmd_text, this->reason_text] = count();
	@average[this->cmd_text, this->reason_text] = avg(this->delta);
	@total[this->cmd_text, this->reason_text] = sum(this->delta);

	start[arg0] = 0;
}

dtrace:::END
{
	normalize(@total, 1000);
	printf("\n  %-36s %8s %8s %10s %10s\n", "IDE COMMAND",
	    "REASON", "COUNT", "AVG(us)", "TOTAL(ms)");
	printa("  %-36s %8s %@8d %@10d %@10d\n", @num, @average, @total);
}
