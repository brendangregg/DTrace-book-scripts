#!/usr/sbin/dtrace -s
/*
 * sotop.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option destructive

syscall::read*:entry,
syscall::recv*:entry
/fds[arg0].fi_fs == "sockfs" || fds[arg0].fi_name == "<socket>"/
{
	self->read = 1;
}

syscall::read*:return,
syscall::recv*:return
/self->read/
{
	this->size = (int)arg0 > 0 ? arg0 : 0;
	@rc[execname, pid] = count();
	@rb[execname, pid] = sum(this->size);
	self->read = 0;
}

syscall::write*:entry,
syscall::send*:entry
/fds[arg0].fi_fs == "sockfs" || fds[arg0].fi_name == "<socket>"/
{
	/* this under-counts writev() size (assumes iov_len is 1) */
	this->size = arg2;
	@wc[execname, pid] = count();
	@wb[execname, pid] = sum(this->size);
}

profile:::profile-100hz
{
	/* will sum %CPUs on multi-core systems */
	@cpu[execname, pid] = count();
}

profile:::tick-1sec
{
	normalize(@rb, 1024); normalize(@wb, 1024);
	system("clear");
	printf("  %-16s %-8s %8s %8s %10s %10s %8s\n", "PROCESS", "PID",
	    "READS", "WRITES", "READ_KB", "WRITE_KB", "CPU");
	setopt("aggsortpos", "4"); setopt("aggsortrev", "4");
	printa("  %-16s %-8d %@8d %@8d %@10d %@10d %@8d\n",
	    @rc, @wc, @rb, @wb, @cpu);
	trunc(@rc); trunc(@rb); trunc(@wc); trunc(@wb); trunc(@cpu);
}
