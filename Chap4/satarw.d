#!/usr/sbin/dtrace -s
/*
 * satarw.d
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
	 * SATA_DIR of type 1 normally means no-data, but we can call it
	 * sync-cache as that's the only type 1 we are tracing.
	 */
	sata_dir[1] = "sync-cache";
	sata_dir[2] = "read";
	sata_dir[4] = "write";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

/* cache the I/O size while it is still easy to determine */
fbt::sd_start_cmds:entry
{
	/* see the sd_start_cmds() source to understand the following logic */
	this->bp = args[1] != NULL ? args[1] : args[0]->un_waitq_headp;
	self->size = this->bp != NULL ? this->bp->b_bcount : 0;
}

fbt::sd_start_cmds:return { self->size = 0; }

/* trace generic SATA driver functions for read, write and sync-cache */
fbt::sata_txlt_read:entry,
fbt::sata_txlt_write:entry,
fbt::sata_txlt_synchronize_cache:entry
{
	this->sata_pkt = args[0]->txlt_sata_pkt;
	start[(uint64_t)this->sata_pkt] = timestamp;
	size[(uint64_t)this->sata_pkt] = self->size;
}

/* SATA command completed */
fbt::sata_pkt_free:entry
/start[(uint64_t)args[0]->txlt_sata_pkt]/
{
	this->sata_pkt = args[0]->txlt_sata_pkt;
	this->delta = (timestamp - start[(uint64_t)this->sata_pkt]) / 1000;
	this->size = size[(uint64_t)this->sata_pkt];
	this->dir =
	    this->sata_pkt->satapkt_cmd.satacmd_flags.sata_data_direction;
	this->dir_text = sata_dir[this->dir] != NULL ?
	    sata_dir[this->dir] : "<none>";

	@num[this->dir_text] = count();
	@avg_size[this->dir_text] = avg(this->size);
	@avg_time[this->dir_text] = avg(this->delta);
	@sum_size[this->dir_text] = sum(this->size);
	@sum_time[this->dir_text] = sum(this->delta);
	@plot_size[this->dir_text] = quantize(this->size);
	@plot_time[this->dir_text] = quantize(this->delta);

	start[(uint64_t)this->sata_pkt] = 0;
	size[(uint64_t)this->sata_pkt] = 0;
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
	printf("\n\nSATA I/O size (bytes):\n");
	printa(@plot_size);
	printf("\nSATA I/O latency (us):\n");
	printa(@plot_time);
}
