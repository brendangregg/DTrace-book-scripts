#!/usr/sbin/dtrace -s
/*
 * mptlatency.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

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
}

sdt:mpt::io-time-on-hba-non-a-reply
{
	this->mpt = (mpt_t *)arg0;
	this->mpt_cmd = (mpt_cmd_t *)arg1;

	this->mpt_name = strjoin("mpt", lltostr(this->mpt->m_instance));
	this->delta = (this->mpt_cmd->cmd_io_done_time -
	    this->mpt_cmd->cmd_io_start_time) / 1000;
	this->code = *this->mpt_cmd->cmd_cdb;
	this->cmd_text = scsi_cmd[this->code] != NULL ?
	    scsi_cmd[this->code] : lltostr(this->code);
	@[this->mpt_name, this->cmd_text] = quantize(this->delta);
}

dtrace:::END
{
	printf("Command Latency (us):\n");
	printa(@);
}
