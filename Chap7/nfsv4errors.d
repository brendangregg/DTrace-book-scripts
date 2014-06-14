#!/usr/sbin/dtrace -s
/*
 * nfsv4errors.d
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
	/* See NFS4ERR_* in /usr/include/nfs/nfs4_kprot.h */
	nfs4err[0] = "NFS4_OK";
	nfs4err[1] = "PERM";
	nfs4err[2] = "NOENT";
	nfs4err[5] = "IO";
	nfs4err[6] = "NXIO";
	nfs4err[13] = "ACCESS";
	nfs4err[17] = "EXIST";
	nfs4err[18] = "XDEV";
	nfs4err[20] = "NOTDIR";
	nfs4err[21] = "ISDIR";
	nfs4err[22] = "INVAL";
	nfs4err[27] = "FBIG";
	nfs4err[28] = "NOSPC";
	nfs4err[30] = "ROFS";
	nfs4err[31] = "MLINK";
	nfs4err[63] = "NAMETOOLONG";
	nfs4err[66] = "NOTEMPTY";
	nfs4err[69] = "DQUOT";
	nfs4err[70] = "STALE";
	nfs4err[10001] = "BADHANDLE";
	nfs4err[10003] = "BAD_COOKIE";
	nfs4err[10004] = "NOTSUPP";
	nfs4err[10005] = "TOOSMALL";
	nfs4err[10006] = "SERVERFAULT";
	nfs4err[10007] = "BADTYPE";
	nfs4err[10008] = "DELAY";
	nfs4err[10009] = "SAME";
	nfs4err[10010] = "DENIED";
	nfs4err[10011] = "EXPIRED";
	nfs4err[10012] = "LOCKED";
	nfs4err[10013] = "GRACE";
	nfs4err[10014] = "FHEXPIRED";
	nfs4err[10015] = "SHARE_DENIED";
	nfs4err[10016] = "WRONGSEC";
	nfs4err[10017] = "CLID_INUSE";
	nfs4err[10018] = "RESOURCE";
	nfs4err[10019] = "MOVED";
	nfs4err[10020] = "NOFILEHANDLE";
	nfs4err[10021] = "MINOR_VERS_MISMATCH";
	nfs4err[10022] = "STALE_CLIENTID";
	nfs4err[10023] = "STALE_STATEID";
	nfs4err[10024] = "OLD_STATEID";
	nfs4err[10025] = "BAD_STATEID";
	nfs4err[10026] = "BAD_SEQID";
	nfs4err[10027] = "NOT_SAME";
	nfs4err[10028] = "LOCK_RANGE";
	nfs4err[10029] = "SYMLINK";
	nfs4err[10030] = "RESTOREFH";
	nfs4err[10031] = "LEASE_MOVED";
	nfs4err[10032] = "ATTRNOTSUPP";
	nfs4err[10033] = "NO_GRACE";
	nfs4err[10034] = "RECLAIM_BAD";
	nfs4err[10035] = "RECLAIM_CONFLICT";
	nfs4err[10036] = "BADXDR";
	nfs4err[10037] = "LOCKS_HELD";
	nfs4err[10038] = "OPENMODE";
	nfs4err[10039] = "BADOWNER";
	nfs4err[10040] = "BADCHAR";
	nfs4err[10041] = "BADNAME";
	nfs4err[10042] = "BAD_RANGE";
	nfs4err[10043] = "LOCK_NOTSUPP";
	nfs4err[10044] = "OP_ILLEGAL";
	nfs4err[10045] = "DEADLOCK";
	nfs4err[10046] = "FILE_OPEN";
	nfs4err[10047] = "ADMIN_REVOKED";
	nfs4err[10048] = "CB_PATH_DOWN";

	printf(" %-18s %5s %-12s %-16s %s\n", "NFSv4 EVENT", "ERR", "CODE",
	    "CLIENT", "PATHNAME");
}

nfsv4:::op-*-done
/args[2]->status != 0 && args[2]->status != 10009/
{
	this->err = args[2]->status;
	this->str = nfs4err[this->err] != NULL ? nfs4err[this->err] : "?";
	printf(" %-18s %5d %-12s %-16s %s\n", probename, this->err,
	    this->str, args[0]->ci_remote, args[1]->noi_curpath);
}
