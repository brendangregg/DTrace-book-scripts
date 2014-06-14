#!/usr/sbin/dtrace -s
/*
 * spasync.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

inline int MIN_MS = 1;

dtrace:::BEGIN
{
	printf("Tracing ZFS spa_sync() slower than %d ms...\n", MIN_MS);
	@bytes = sum(0);
}

fbt::spa_sync:entry
/!self->start/
{
	in_spa_sync = 1;
	self->start = timestamp;
	self->spa = args[0];
}

io:::start
/in_spa_sync/
{
	@io = count();
	@bytes = sum(args[0]->b_bcount);
}

fbt::spa_sync:return
/self->start && (this->ms = (timestamp - self->start) / 1000000) > MIN_MS/
{
	normalize(@bytes, 1048576);
	printf("%-20Y %-10s %6d ms, ", walltimestamp,
	    stringof(self->spa->spa_name), this->ms);
	printa("%@d MB %@d I/O\n", @bytes, @io);
}

fbt::spa_sync:return
{
	self->start = 0; self->spa = 0; in_spa_sync = 0;
	clear(@bytes); clear(@io);
}
