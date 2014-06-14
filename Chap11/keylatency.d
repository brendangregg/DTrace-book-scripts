#!/usr/sbin/dtrace -s
/*
 * keylatency.d
 *
 * Example script from Chapter 11 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

/* process name to monitor */
inline string TARGET = "bash";

self string lastkey;

dtrace:::BEGIN
{
	printf("Tracing %s keystrokes...  Hit Ctrl-C to end.\n", TARGET);
}

syscall::read:entry
/execname == TARGET && arg0 == 0/
{
	self->buf = arg1;
	self->start = timestamp;
}

syscall::read:return
/self->buf && arg0 == 1/
{
	this->latency = timestamp - self->start;
	this->key = stringof((char *)copyin(self->buf, arg0));
	this->key = this->key == "\r" ? "NL" : this->key;	/* return */
	this->key = this->key == "\t" ? "TAB" : this->key;	/* tab */
	this->key = this->key == "\177" ? "BS" : this->key;	/* backspace */
	@a[self->lastkey != NULL ? self->lastkey : " ", this->key] =
	    avg(this->latency);
	@c[self->lastkey != NULL ? self->lastkey : " ", this->key] = count();
	self->lastkey = this->key;
	self->start = 0;
}

syscall::read:return /self->buf/ { self->buf = 0; self->start = 0; }

dtrace:::END
{
	normalize(@a, 1000000);
	printf("Average Keystroke Latency for %s processes (ms):\n\n", TARGET);
	printf("%34s %8s\n", "LATENCY", "COUNT");
	printa("%16s -> %3s %10@d %@8d\n", @a, @c);
}
