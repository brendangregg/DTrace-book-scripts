#!/usr/sbin/dtrace -s
/*
 * scsireasons.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	/*
	 * The following was generated from the CMD_* pkt_reason definitions
	 * in /usr/include/sys/scsi/scsi_pkt.h using sed.
	 */
	scsi_reason[0] = "no transport errors- normal completion";
	scsi_reason[1] = "transport stopped with not normal state";
	scsi_reason[2] = "dma direction error occurred";
	scsi_reason[3] = "unspecified transport error";
	scsi_reason[4] = "Target completed hard reset sequence";
	scsi_reason[5] = "Command transport aborted on request";
	scsi_reason[6] = "Command timed out";
	scsi_reason[7] = "Data Overrun";
	scsi_reason[8] = "Command Overrun";
	scsi_reason[9] = "Status Overrun";
	scsi_reason[10] = "Message not Command Complete";
	scsi_reason[11] = "Target refused to go to Message Out phase";
	scsi_reason[12] = "Extended Identify message rejected";
	scsi_reason[13] = "Initiator Detected Error message rejected";
	scsi_reason[14] = "Abort message rejected";
	scsi_reason[15] = "Reject message rejected";
	scsi_reason[16] = "No Operation message rejected";
	scsi_reason[17] = "Message Parity Error message rejected";
	scsi_reason[18] = "Bus Device Reset message rejected";
	scsi_reason[19] = "Identify message rejected";
	scsi_reason[20] = "Unexpected Bus Free Phase occurred";
	scsi_reason[21] = "Target rejected our tag message";
	scsi_reason[22] = "Command transport terminated on request";
	scsi_reason[24] = "The device has been removed";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

fbt::scsi_init_pkt:entry
/args[2] != NULL/
{
	self->name = xlate <devinfo_t *>(args[2])->dev_statname;
}

fbt::scsi_init_pkt:return
{
	pkt_name[arg1] = self->name;
	self->name = 0;
}

fbt::scsi_destroy_pkt:entry
{
	this->code = args[0]->pkt_reason;
	this->reason = scsi_reason[this->code] != NULL ?
	    scsi_reason[this->code] : "<unknown reason code>";
	@all[this->reason] = count();
}

fbt::scsi_destroy_pkt:entry
/this->code != 0/
{
	this->name = pkt_name[arg0] != NULL ? pkt_name[arg0] : "<unknown>";
	    @errors[pkt_name[arg0], this->reason] = count();
}

fbt::scsi_destroy_pkt:entry
{
	pkt_name[arg0] = 0;
}

dtrace:::END
{
	printf("\nSCSI I/O completion reason summary:\n");
	    printa(@all);
	printf("\n\nSCSI I/O reason errors by disk device and reason:\n\n");
	printf("  %-16s  %-44s %s\n", "DEVICE", "ERROR REASON", "COUNT");
	printa("  %-16s  %-44s %@d\n", @errors);
}
