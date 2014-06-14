#!/usr/sbin/dtrace -s
/*
 * scsirw.d
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
	printf("Tracing... Hit Ctrl-C to end.\n");
}

fbt::sd_setup_rw_pkt:entry { self->in__sd_setup_rw_pkt = 1; }
fbt::sd_setup_rw_pkt:return { self->in__sd_setup_rw_pkt = 0; }

fbt::scsi_init_pkt:entry
/self->in__sd_setup_rw_pkt/
{
	self->buf = args[2];
}

/* Store start time and size for read and write commands */
fbt::scsi_init_pkt:return
/self->buf/
{
	start[arg1] = timestamp;
	size[arg1] = self->buf->b_bcount;
	dir[arg1] = self->buf->b_flags & B_WRITE ? "write" : "read";
	self->buf = 0;
}

fbt::sd_send_scsi_SYNCHRONIZE_CACHE:entry { self->in__sync_cache = 1; }
fbt::sd_send_scsi_SYNCHRONIZE_CACHE:return { self->in__sync_cache = 0; }

/* Store start time for sync-cache commands */
fbt::scsi_init_pkt:return
/self->in__sync_cache/
{
	start[arg1] = timestamp;
	dir[arg1] = "sync-cache";
}

/* SCSI command completed */
fbt::scsi_destroy_pkt:entry
/start[arg0]/
{
	this->delta = (timestamp - start[arg0]) / 1000;
	this->size = size[arg0];
	this->dir = dir[arg0];

	@num[this->dir] = count();
	@avg_size[this->dir] = avg(this->size);
	@avg_time[this->dir] = avg(this->delta);
	@sum_size[this->dir] = sum(this->size);
	@sum_time[this->dir] = sum(this->delta);
	@plot_size[this->dir] = quantize(this->size);
	@plot_time[this->dir] = quantize(this->delta);

	start[arg0] = 0;
	size[arg0] = 0;
	dir[arg0] = 0;
}

dtrace:::END
{
	normalize(@avg_size, 1024);
	normalize(@sum_size, 1048576);
	normalize(@sum_time, 1000);
	printf("  %-10s  %10s  %10s %10s  %10s %12s\n", "DIR",
	    "COUNT", "AVG(KB)", "TOTAL(MB)", "AVG(us)", "TOTAL(ms)");
	printa("  %-10s  %@10d  %@10d %@10d  %@10d %@12d\n", @num,
	    @avg_size, @sum_size, @avg_time, @sum_time);
	printf("\n\nSCSI I/O size (bytes):\n");
	printa(@plot_size);
	printf("\nSCSI I/O latency (us):\n");
	printa(@plot_time);
}
