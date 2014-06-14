#!/usr/sbin/dtrace -s
/*
 * ziotype.d
 *
 * Example script from Chapter 5 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	/* see /usr/include/sys/fs/zfs.h */
	ziotype[0] = "null";
	ziotype[1] = "read";
	ziotype[2] = "write";
	ziotype[3] = "free";
	ziotype[4] = "claim";
	ziotype[5] = "ioctl";
	trace("Tracing ZIO...  Output interval 5 seconds, or Ctrl-C.\n");
}

fbt::zio_create:return
/args[1]->io_type/		/* skip null */
{
	@[stringof(args[1]->io_spa->spa_name),
	    ziotype[args[1]->io_type] != NULL ?
	    ziotype[args[1]->io_type] : "?"] = count();
}

profile:::tick-5sec,
dtrace:::END
{
	printf("\n %-32s %-10s %10s\n", "POOL", "ZIO_TYPE", "CREATED");
	printa(" %-32s %-10s %@10d\n", @);
	trunc(@);
}
