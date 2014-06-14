#!/usr/sbin/dtrace -s
/*
 * nfsv3errors.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	/* See NFS3ERR_* in /usr/include/nfs/nfs.h */
	nfs3err[0] = "NFS3_OK";
	nfs3err[1] = "PERM";
	nfs3err[2] = "NOENT";
	nfs3err[5] = "IO";
	nfs3err[6] = "NXIO";
	nfs3err[13] = "ACCES";
	nfs3err[17] = "EXIST";
	nfs3err[18] = "XDEV";
	nfs3err[19] = "NODEV";
	nfs3err[20] = "NOTDIR";
	nfs3err[21] = "ISDIR";
	nfs3err[22] = "INVAL";
	nfs3err[27] = "FBIG";
	nfs3err[28] = "NOSPC";
	nfs3err[30] = "ROFS";
	nfs3err[31] = "MLINK";
	nfs3err[63] = "NAMETOOLONG";
	nfs3err[66] = "NOTEMPTY";
	nfs3err[69] = "DQUOT";
	nfs3err[70] = "STALE";
	nfs3err[71] = "REMOTE";
	nfs3err[10001] = "BADHANDLE";
	nfs3err[10002] = "NOT_SYNC";
	nfs3err[10003] = "BAD_COOKIE";
	nfs3err[10004] = "NOTSUPP";
	nfs3err[10005] = "TOOSMALL";
	nfs3err[10006] = "SERVERFAULT";
	nfs3err[10007] = "BADTYPE";
	nfs3err[10008] = "JUKEBOX";

	printf(" %-18s %5s %-12s %-16s %s\n", "NFSv3 EVENT", "ERR", "CODE",
	    "CLIENT", "PATHNAME");
}

nfsv3:::op-*-done
/args[2]->status != 0/
{
	this->err = args[2]->status;
	this->str = nfs3err[this->err] != NULL ? nfs3err[this->err] : "?";
	    printf(" %-18s %5d %-12s %-16s %s\n", probename, this->err,
	this->str, args[0]->ci_remote, args[1]->noi_curpath);
}
