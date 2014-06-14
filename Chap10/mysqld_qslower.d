#!/usr/sbin/dtrace -s
/*
 * mysqld_qslower.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%5s %5s %5s %5s %s\n", "QRYms", "EXCms", "CPUms",
	    "CACHE", "QUERY");
	min_ns = $1 * 1000000;
}

mysql*:::query-start
{
	self->query = copyinstr(arg0);
	self->start = timestamp;
	self->vstart = vtimestamp;
}

mysql*:::query-cache-hit,
mysql*:::query-cache-miss
{
	self->cache = probename == "query-cache-hit" ? "hit" : "miss";
}

mysql*:::query-exec-start
{
	self->estart = timestamp;
}

mysql*:::query-exec-done
/self->estart/
{
	self->exec = timestamp - self->estart;
	self->estart = 0;
}

mysql*:::query-done
/self->start && (timestamp - self->start) >= min_ns/
{
	this->time = (timestamp - self->start) / 1000000;
	this->vtime = (vtimestamp - self->vstart) / 1000000;
	this->etime = self->exec / 1000000;
	printf("%5d %5d %5d %5s %s\n", this->time, this->etime, this->vtime,
	    self->cache, self->query);
}

mysql*:::query-done
{
	self->start = 0; self->vstart = 0; self->exec = 0;
	self->cache = 0; self->query = 0;
}
