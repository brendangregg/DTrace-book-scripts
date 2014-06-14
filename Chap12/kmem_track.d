#!/usr/sbin/dtrace -s
/*
 * kmem_track.d
 *
 * Example script from Chapter 12 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

fbt::kmem_cache_alloc:entry
{
	@alloc[args[0]->cache_name] = count();
}
fbt::kmem_cache_free:entry
{
	@free[args[0]->cache_name] = count();
}
tick-1sec
{
	printf("%-32s %-8s %-8s\n", "CACHE NAME", "ALLOCS", "FREES");
	printa("%-32s %-@8d %-@8d\n", @alloc, @free);
	trunc(@alloc); trunc(@free);
}
