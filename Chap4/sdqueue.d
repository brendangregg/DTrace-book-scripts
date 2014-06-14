#!/usr/sbin/dtrace -s
/*
 * sdqueue.d
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

fbt::sd_add_buf_to_waitq:entry
/args[1]->b_dip/
{
	start_time[arg1] = timestamp;
}

sdt:::scsi-transport-dispatch
/this->start = start_time[arg0]/
{
	this->delta = (timestamp - this->start) / 1000;
	this->bp = (buf_t *)arg0;
	this->dev = xlate <devinfo_t *>(this->bp)->dev_statname;
	this->path = xlate <devinfo_t *>(this->bp)->dev_pathname;
	@avg[this->dev, this->path] = avg(this->delta);
	@plot[this->dev, this->path] = lquantize(this->delta / 1000, 0, 1000,
	    100);
	start_time[arg0] = 0;
}

dtrace:::END
{
	printf("Wait queue time by disk (ms):\n");
	printa("\n  %-12s %-50s\n%@d", @plot);
	printf("\n\n  %-12s %-50s %12s\n", "DEVICE", "PATH", "AVG_WAIT(us)");
	printa("  %-12s %-50s %@12d\n", @avg);
}
