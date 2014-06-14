#!/usr/sbin/dtrace -s
/*
 * scsicmds.d
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
	/*
	 * The following was generated from the SCSI_CMDS_KEY_STRINGS
	 * definitions in /usr/include/sys/scsi/generic/commands.h using sed.
	 */
	scsi_cmd[0x00] = "test_unit_ready";
	scsi_cmd[0x01] = "rezero/rewind";
	scsi_cmd[0x03] = "request_sense";
	scsi_cmd[0x04] = "format";
	scsi_cmd[0x05] = "read_block_limits";
	scsi_cmd[0x07] = "reassign";
	scsi_cmd[0x08] = "read";
	scsi_cmd[0x0a] = "write";
	scsi_cmd[0x0b] = "seek";
	scsi_cmd[0x0f] = "read_reverse";
	scsi_cmd[0x10] = "write_file_mark";
	scsi_cmd[0x11] = "space";
	scsi_cmd[0x12] = "inquiry";
	scsi_cmd[0x13] = "verify";
	scsi_cmd[0x14] = "recover_buffer_data";
	scsi_cmd[0x15] = "mode_select";
	scsi_cmd[0x16] = "reserve";
	scsi_cmd[0x17] = "release";
	scsi_cmd[0x18] = "copy";
	scsi_cmd[0x19] = "erase_tape";
	scsi_cmd[0x1a] = "mode_sense";
	scsi_cmd[0x1b] = "load/start/stop";
	scsi_cmd[0x1c] = "get_diagnostic_results";
	scsi_cmd[0x1d] = "send_diagnostic_command";
	scsi_cmd[0x1e] = "door_lock";
	scsi_cmd[0x23] = "read_format_capacity";
	scsi_cmd[0x25] = "read_capacity";
	scsi_cmd[0x28] = "read(10)";
	scsi_cmd[0x2a] = "write(10)";
	scsi_cmd[0x2b] = "seek(10)";
	scsi_cmd[0x2e] = "write_verify";
	scsi_cmd[0x2f] = "verify(10)";
	scsi_cmd[0x30] = "search_data_high";
	scsi_cmd[0x31] = "search_data_equal";
	scsi_cmd[0x32] = "search_data_low";
	scsi_cmd[0x33] = "set_limits";
	scsi_cmd[0x34] = "read_position";
	scsi_cmd[0x35] = "synchronize_cache";
	scsi_cmd[0x37] = "read_defect_data";
	scsi_cmd[0x39] = "compare";
	scsi_cmd[0x3a] = "copy_verify";
	scsi_cmd[0x3b] = "write_buffer";
	scsi_cmd[0x3c] = "read_buffer";
	scsi_cmd[0x3e] = "read_long";
	scsi_cmd[0x3f] = "write_long";
	scsi_cmd[0x44] = "report_densities/read_header";
	scsi_cmd[0x4c] = "log_select";
	scsi_cmd[0x4d] = "log_sense";
	scsi_cmd[0x55] = "mode_select(10)";
	scsi_cmd[0x56] = "reserve(10)";
	scsi_cmd[0x57] = "release(10)";
	scsi_cmd[0x5a] = "mode_sense(10)";
	scsi_cmd[0x5e] = "persistent_reserve_in";
	scsi_cmd[0x5f] = "persistent_reserve_out";
	scsi_cmd[0x80] = "write_file_mark(16)";
	scsi_cmd[0x81] = "read_reverse(16)";
	scsi_cmd[0x83] = "extended_copy";
	scsi_cmd[0x88] = "read(16)";
	scsi_cmd[0x8a] = "write(16)";
	scsi_cmd[0x8c] = "read_attribute";
	scsi_cmd[0x8d] = "write_attribute";
	scsi_cmd[0x8f] = "verify(16)";
	scsi_cmd[0x91] = "space(16)";
	scsi_cmd[0x92] = "locate(16)";
	scsi_cmd[0x9e] = "service_action_in(16)";
	scsi_cmd[0x9f] = "service_action_out(16)";
	scsi_cmd[0xa0] = "report_luns";
	scsi_cmd[0xa2] = "security_protocol_in";
	scsi_cmd[0xa3] = "maintenance_in";
	scsi_cmd[0xa4] = "maintenance_out";
	scsi_cmd[0xa8] = "read(12)";
	scsi_cmd[0xa9] = "service_action_out(12)";
	scsi_cmd[0xaa] = "write(12)";
	scsi_cmd[0xab] = "service_action_in(12)";
	scsi_cmd[0xac] = "get_performance";
	scsi_cmd[0xAF] = "verify(12)";
	scsi_cmd[0xb5] = "security_protocol_out";
	printf("Tracing... Hit Ctrl-C to end.\n");
}
fbt::scsi_transport:entry
{
	this->dev =
	    (struct dev_info *)args[0]->pkt_address.a_hba_tran->tran_hba_dip;
	this->nodename = this->dev != NULL ?
	    stringof(this->dev->devi_node_name) : "<unknown>";
	this->code = *args[0]->pkt_cdbp;
	this->cmd = scsi_cmd[this->code] != NULL ?
	    scsi_cmd[this->code] : lltostr(this->code);
	@[this->nodename, this->cmd] = count();
}
dtrace:::END
{
	printf("  %-24s %-36s  %s\n", "DEVICE NODE", "SCSI COMMAND", "COUNT");
	printa("  %-24s %-36s  %@d\n", @);
}
