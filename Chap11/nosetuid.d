#!/usr/sbin/dtrace -s
/*
 * nosetuid.d
 *
 * Example script from Chapter 11 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option destructive

inline int ALLOWED_UID = 517;

dtrace:::BEGIN
{
	printf("Watching setuid(), allowing only uid %d...\n", ALLOWED_UID);
}

/*
 * Kill setuid() processes who are becomming root, from non-root, and who
 * are not the allowed UID.
 */
syscall::setuid:entry
/arg0 == 0 && curpsinfo->pr_uid != 0 && curpsinfo->pr_uid != ALLOWED_UID/
{
	printf("%Y KILLED %s %d -> %d\n", walltimestamp, execname,
	    curpsinfo->pr_uid, arg0);
	raise(9);
}
