#!/usr/sbin/dtrace -s
/*
 * ideerr.d
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
	 * These command and error descriptions are from the DCMD_* and DERR_*
	 * definitions in /usr/include/sys/dktp/dadkio.h:
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

	derr[0] = "success";
	derr[1] = "address mark not found";
	derr[2] = "track 0 not found";
	derr[3] = "aborted command";
	derr[4] = "write fault";
	derr[5] = "ID not found";
	derr[6] = "drive busy";
	derr[7] = "uncorrectable data error";
	derr[8] = "bad block detected";
	derr[9] = "invalid cdb";
	derr[10] = "hard device error- no retry";
	derr[11] = "Illegal length indication";
	derr[12] = "End of media detected";
	derr[13] = "Media change requested";
	derr[14] = "Recovered from error";
	derr[15] = "Device not ready";
	derr[16] = "Medium error";
	derr[17] = "Hardware error";
	derr[18] = "Illegal request";
	derr[19] = "Unit attention";
	derr[20] = "Data protection";
	derr[21] = "Miscompare";
	derr[22] = "Interface CRC error";
	derr[23] = "Reserved";

	/* from CPS_* definitions in /usr/include/sys/dktp/cmpkt.h */
	reason[0] = "success";
	reason[1] = "failure";
	reason[2] = "fail+err";
	reason[3] = "aborted";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

fbt::dadk_pktcb:entry
{
	this->pktp = args[0];

	this->cmd = *(char *)this->pktp->cp_cdbp;
	this->cmd_text = dcmd[this->cmd] != NULL ?
	    dcmd[this->cmd] : lltostr(this->cmd);
	this->reason = this->pktp->cp_reason;
	this->reason_text = reason[this->reason] != NULL ?
	    reason[this->reason] : lltostr(this->reason);
	this->err = *(char *)this->pktp->cp_scbp;
	this->err_text = derr[this->err] != NULL ?
	    derr[this->err] : lltostr(this->err);

	@[this->cmd_text, this->reason_text, this->err_text] = count();
}

dtrace:::END
{
	printf("%-36s %8s %27s %s\n", "IDE COMMAND", "REASON", "ERROR",
	    "COUNT");
	printa("%-36s %8s %27s %@d\n", @);
}
