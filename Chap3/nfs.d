#!/usr/sbin/dtrace -s
/*
 * nfs.d
 *
 * Example script from Chapter 3 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

fbt:nfs:nfs4_getapage:entry
/execname == "m2loader"/
{
	self->st = timestamp;
	@calls = count();
}
fbt:nfs:nfs4_getapage:return
/self->st/
{
	@mint = min(timestamp - self->st);
	@maxt = max(timestamp - self->st);
	@avgt = avg(timestamp - self->st);
	@t["ns"] = quantize(timestamp - self->st);
	self->st = 0;
}
END
{
	normalize(@mint, 1000);
	normalize(@maxt, 1000);
	normalize(@avgt, 1000);
	printf("%-8s %-8s %-8s %-8s\n",
	    "CALLS", "MIN(us)", "MAX(us)", "AVG(us)");
	printa("%-@8d %-@8d %-@8d %-@8d\n", @calls, @mint, @maxt, @avgt);
	printf("\n");
	printa(@t);
}
