#!/usr/sbin/dtrace -s
/*
 * mptevents.d
 *
 * Example script from Chapter 4 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	/*
	 * These MPI_EVENT_* definitions are from uts/common/sys/mpt/mpi_ioc.h
	 */

	mpi_event[0x00000000] = "NONE";
	mpi_event[0x00000001] = "LOG_DATA";
	mpi_event[0x00000002] = "STATE_CHANGE";
	mpi_event[0x00000003] = "UNIT_ATTENTION";
	mpi_event[0x00000004] = "IOC_BUS_RESET";
	mpi_event[0x00000005] = "EXT_BUS_RESET";
	mpi_event[0x00000006] = "RESCAN";
	mpi_event[0x00000007] = "LINK_STATUS_CHANGE";
	mpi_event[0x00000008] = "LOOP_STATE_CHANGE";
	mpi_event[0x00000009] = "LOGOUT";
	mpi_event[0x0000000A] = "EVENT_CHANGE";
	mpi_event[0x0000000B] = "INTEGRATED_RAID";
	mpi_event[0x0000000C] = "SCSI_DEVICE_STATUS_CHANGE";
	mpi_event[0x0000000D] = "ON_BUS_TIMER_EXPIRED";
	mpi_event[0x0000000E] = "QUEUE_FULL";
	mpi_event[0x0000000F] = "SAS_DEVICE_STATUS_CHANGE";
	mpi_event[0x00000010] = "SAS_SES";
	mpi_event[0x00000011] = "PERSISTENT_TABLE_FULL";
	mpi_event[0x00000012] = "SAS_PHY_LINK_STATUS";
	mpi_event[0x00000013] = "SAS_DISCOVERY_ERROR";
	mpi_event[0x00000014] = "IR_RESYNC_UPDATE";
	mpi_event[0x00000015] = "IR2";
	mpi_event[0x00000016] = "SAS_DISCOVERY";
	mpi_event[0x00000017] = "SAS_BROADCAST_PRIMITIVE";
	mpi_event[0x00000018] = "SAS_INIT_DEVICE_STATUS_CHANGE";
	mpi_event[0x00000019] = "SAS_INIT_TABLE_OVERFLOW";
	mpi_event[0x0000001A] = "SAS_SMP_ERROR";
	mpi_event[0x0000001B] = "SAS_EXPANDER_STATUS_CHANGE";
	mpi_event[0x00000021] = "LOG_ENTRY_ADDED";

	sas_discovery[0x00000000] = "SAS_DSCVRY_COMPLETE";
	sas_discovery[0x00000001] = "SAS_DSCVRY_IN_PROGRESS";

	dev_stat[0x03] = "ADDED";
	dev_stat[0x04] = "NOT_RESPONDING";
	dev_stat[0x05] = "SMART_DATA";
	dev_stat[0x06] = "NO_PERSIST_ADDED";
	dev_stat[0x07] = "UNSUPPORTED";
	dev_stat[0x08] = "INTERNAL_DEVICE_RESET";
	dev_stat[0x09] = "TASK_ABORT_INTERNAL";
	dev_stat[0x0A] = "ABORT_TASK_SET_INTERNAL";
	dev_stat[0x0B] = "CLEAR_TASK_SET_INTERNAL";
	dev_stat[0x0C] = "QUERY_TASK_INTERNAL";
	dev_stat[0x0D] = "ASYNC_NOTIFICATION";
	dev_stat[0x0E] = "CMPL_INTERNAL_DEV_RESET";
	dev_stat[0x0F] = "CMPL_TASK_ABORT_INTERNAL";

	printf("%-20s  %-6s %-3s    %s\n", "TIME", "MODULE", "CPU", "EVENT");
}
sdt:mpt::handle-event-sync
{
	this->mpt = (mpt_t *)arg0;
	this->mpt_name = strjoin("mpt", lltostr(this->mpt->m_instance));
	this->event_text = mpi_event[arg1] != NULL ?
	    mpi_event[arg1] : lltostr(arg1);
	printf("%-20Y  %-6s %-3d -> %s\n", walltimestamp, this->mpt_name, cpu,
	    this->event_text);
}
sdt:mpt::handle-event-sync
/arg1 == 0x00000016/
{
	self->mpt = (mpt_t *)arg0;
	self->discovery = 1;
}
fbt::mpt_handle_event_sync:return
/self->discovery/
{
	/* remove the PHY_BITS from the discovery status */
	this->cond = self->mpt->m_discovery & 0x0000FFFF;
	this->cond_text = sas_discovery[this->cond] != NULL ?
	    sas_discovery[this->cond] : lltostr(this->cond);
	printf("%-20Y  %-6s %-3d    -> discovery status: %s\n", walltimestamp,
	    this->mpt_name, cpu, this->cond_text);
	self->mpt = 0;
	self->discovery = 0;
}
sdt:mpt::device-status-change
{
	this->mpt = (mpt_t *)arg0;
	this->mpt_name = strjoin("mpt", lltostr(this->mpt->m_instance));
	this->reason = arg2;
	this->reason_text = dev_stat[this->reason] != NULL ?
	    dev_stat[this->reason] : lltostr(this->reason);
	printf("%-20Y  %-6s %-3d    -> device change: %s\n", walltimestamp,
	    this->mpt_name, cpu, this->reason_text);
	printf("%-20Y  %-6s %-3d       wwn=%x\n", walltimestamp,
	    this->mpt_name, cpu, arg3);
}
sdt:mpt::event-sas-phy-link-status
{
	this->mpt = (mpt_t *)arg0;
	this->mpt_name = strjoin("mpt", lltostr(this->mpt->m_instance));
	this->phynum = arg1;
	printf("%-20Y  %-6s %-3d    -> phy link status, phy=%d\n",
	    walltimestamp, this->mpt_name, cpu, this->phynum);
}
