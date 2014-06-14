#!/usr/sbin/dtrace -s
/*
 * kmem_osx.d
 *
 * Example script from Chapter 12 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

fbt::kmem_alloc:entry
{
	@alloc[arg2] = count();
}
fbt::kmem_free:entry
{
	@free[arg2] = count();
}
END
{
	printf("%-16s %-8s %-8s\n", "SIZE", "ALLOCS", "FREES");
	printa("%-16d %-@8d %-@8d\n", @alloc, @free);
}
