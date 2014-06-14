#!/usr/sbin/dtrace -s
/*
 * iderw.d
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
	 * These commands of interest are from the DCMD_* definitions in
	 * /usr/include/sys/dktp/dadkio.h:
	 */
	dcmd[1] = "Read Sectors/Blocks";
	dcmd[2] = "Write Sectors/Blocks";
	dcmd[27] = "flush write cache";

	/* from CPS_* definitions in /usr/include/sys/dktp/cmpkt.h */
	reason[0] = "success";
	reason[1] = "failure";
	reason[2] = "fail+err";
	reason[3] = "aborted";

	printf("Tracing... Hit Ctrl-C to end.\n");
}

fbt::dadk_pktprep:entry
{
	self->size = args[2]->b_bcount;
}

/* IDE command start */
fbt::dadk_pktprep:return
{
	start[arg1] = timestamp;
	size[arg1] = self->size;
	self->size = 0;
}

/* IDE command completion */
fbt::dadk_pktcb:entry
/start[arg0]/
{
	this->pktp = args[0];
	this->cmd = *((uchar_t *)this->pktp->cp_cdbp);
}

/* Only match desired commands: read/write/flush-cache */
fbt::dadk_pktcb:entry
/start[arg0] && dcmd[this->cmd] != NULL/
{
	this->delta = (timestamp - start[arg0]) / 1000;
	this->cmd_text = dcmd[this->cmd] != NULL ?
	    dcmd[this->cmd] : lltostr(this->cmd);
	this->size = size[arg0];

	@num[this->cmd_text] = count();
	@avg_size[this->cmd_text] = avg(this->size);
	@avg_time[this->cmd_text] = avg(this->delta);
	@sum_size[this->cmd_text] = sum(this->size);
	@sum_time[this->cmd_text] = sum(this->delta);
	@plot_size[this->cmd_text] = quantize(this->size);
	@plot_time[this->cmd_text] = quantize(this->delta);

	start[arg0] = 0;
	size[arg0] = 0;
}

dtrace:::END
{
	normalize(@avg_size, 1024);
	normalize(@sum_size, 1048576);
	normalize(@sum_time, 1000);
	printf("  %-20s  %8s  %10s %10s  %10s %11s\n", "DIR",
	    "COUNT", "AVG(KB)", "TOTAL(MB)", "AVG(us)", "TOTAL(ms)");
	printa("  %-20s  %@8d  %@10d %@10d  %@10d %@11d\n", @num,
	    @avg_size, @sum_size, @avg_time, @sum_time);
	printf("\n\nIDE I/O size (bytes):\n");
	printa(@plot_size);
	printf("\nIDE I/O latency (us):\n");
	printa(@plot_time);
}
