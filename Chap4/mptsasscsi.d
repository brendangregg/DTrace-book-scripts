#!/usr/sbin/dtrace -Cs
/*
 * mptsasscsi.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

/* From uts/common/sys/mpt/mpi_ioc.h */
#define	MPI_PORTFACTS_PORTTYPE_INACTIVE		0x00
#define	MPI_PORTFACTS_PORTTYPE_SCSI		0x01
#define	MPI_PORTFACTS_PORTTYPE_FC		0x10
#define	MPI_PORTFACTS_PORTTYPE_ISCSI		0x20
#define	MPI_PORTFACTS_PORTTYPE_SAS		0x30

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

fbt::mpt_start_cmd:entry
/args[0]->m_port_type[0] == MPI_PORTFACTS_PORTTYPE_SAS/
{
	this->mpt = args[0];
	this->mpt_name = strjoin("mpt", lltostr(this->mpt->m_instance));
	this->node_name = this->mpt->m_dip != NULL ?
	    stringof(((struct dev_info *)this->mpt->m_dip)->devi_node_name) :
	    "<unknown>";
	this->scsi_pkt = args[1]->cmd_pkt;
	this->code = *this->scsi_pkt->pkt_cdbp;
	this->cmd_text = scsi_cmd[this->code] != NULL ?
	    scsi_cmd[this->code] : lltostr(this->code);
	@cmd[this->node_name, this->mpt_name, this->cmd_text] = count();
}

dtrace:::END
{
	printf("  %-16s %-12s %-36s %s\n", "DEVICE NODE", "MODULE", "SCSI CMD",
	    "COUNT");
	printa("  %-16s %-12s %-36s %@d\n", @cmd);
}
