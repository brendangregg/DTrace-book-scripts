#!/usr/sbin/dtrace -s
/*
 * segkmem.d
 *
 * Example script from Chapter 12 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

fbt::segkmem_xalloc:entry
{
	@segkmem_alloc[args[0]->vm_name, arg2] = count();
}
fbt::segkmem_free_vn:entry
{
	@segkmem_free[args[0]->vm_name, arg2] = count();
}
END
{
	printf("%-16s %-8s %-8s %-8s\n",
	    "VMEM NAME", "SIZE", "ALLOCS", "FREES");
	printa("%-16s %-8d %-@8d %-@8d\n", @segkmem_alloc, @segkmem_free);
}
