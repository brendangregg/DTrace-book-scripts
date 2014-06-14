#!/usr/sbin/dtrace -s
/*
 * nfsv3syncwrite.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	/* See /usr/include/nfs/nfs.h */
	stable_how[0] = "Unstable";
	stable_how[1] = "Data_Sync";
	stable_how[2] = "File_Sync";
	printf("Tracing NFSv3 writes and commits... Hit Ctrl-C to end.\n");
}

nfsv3:::op-write-start
{
	@["write", stable_how[args[2]->stable], args[1]->noi_curpath] = count();
}

nfsv3:::op-commit-start
{
	@["commit", "-", args[1]->noi_curpath] = count();
}

dtrace:::END
{
	printf(" %-7s %-10s %-10s %s\n", "OP", "TYPE", "COUNT", "PATH");
	printa(" %-7s %-10s %@-10d %s\n", @);
}
