#!/usr/sbin/dtrace -s
/*
 * scsilatency.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

string scsi_cmd[uchar_t];

dtrace:::BEGIN
{
	/* See /usr/include/sys/scsi/generic/commands.h for the full list. */
	scsi_cmd[0x00] = "test_unit_ready";
	scsi_cmd[0x08] = "read";
	scsi_cmd[0x0a] = "write";
	scsi_cmd[0x12] = "inquiry";
	scsi_cmd[0x17] = "release";
	scsi_cmd[0x1a] = "mode_sense";
	scsi_cmd[0x1b] = "load/start/stop";
	scsi_cmd[0x1c] = "get_diagnostic_results";
	scsi_cmd[0x1d] = "send_diagnostic_command";
	scsi_cmd[0x25] = "read_capacity";
	scsi_cmd[0x28] = "read(10)";
	scsi_cmd[0x2a] = "write(10)";
	scsi_cmd[0x35] = "synchronize_cache";
	scsi_cmd[0x4d] = "log_sense";
	scsi_cmd[0x5e] = "persistent_reserve_in";
	scsi_cmd[0xa0] = "report_luns";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

fbt::scsi_transport:entry
{
	start[arg0] = timestamp;
}

fbt::scsi_destroy_pkt:entry
/start[arg0]/
{
	this->delta = (timestamp - start[arg0]) / 1000;
	this->code = *args[0]->pkt_cdbp;
	this->cmd = scsi_cmd[this->code] != NULL ?
	    scsi_cmd[this->code] : lltostr(this->code);
	this->reason = args[0]->pkt_reason == 0 ? "Success" :
	    strjoin("Fail:", lltostr(args[0]->pkt_reason));

	@num[this->cmd, this->reason] = count();
	@average[this->cmd, this->reason] = avg(this->delta);
	@total[this->cmd, this->reason] = sum(this->delta);

	start[arg0] = 0;
}

dtrace:::END
{
	normalize(@total, 1000);
	printf("\n  %-26s %-12s %11s %11s %11s\n", "SCSI COMMAND",
	    "COMPLETION", "COUNT", "AVG(us)", "TOTAL(ms)");
	printa("  %-26s %-12s %@11d %@11d %@11d\n", @num, @average, @total);
}
