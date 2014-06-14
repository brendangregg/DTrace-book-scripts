#!/usr/sbin/dtrace -s
/*
 * sshcipher2.d
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
	printf("Tracing PID %d ... Hit Ctrl-C for report.\n", $target);
}

pid$target:libcrypto*:*crypt*:entry
{
	self->crypt_start[probefunc] = vtimestamp;
}

pid$target:libcrypto*:*crypt*:return
/self->crypt_start[probefunc]/
{
	this->oncpu = vtimestamp - self->crypt_start[probefunc];
	@cpu[probefunc, "CPU (ns):"] = quantize(this->oncpu);
	@totals["encryption (ns)"] = sum(this->oncpu);
	self->crypt_start[probefunc] = 0;
}
pid$target:libz*:inflate:entry,
pid$target:libz*:deflate:entry
{
	self->compress_start = vtimestamp;
}

pid$target:libz*:inflate:return,
pid$target:libz*:deflate:return
/self->compress_start/
{
	this->oncpu = vtimestamp - self->compress_start;
	@cpu[probefunc, "CPU (ns):"] = quantize(this->oncpu);
	@totals["compression (ns)"] = sum(this->oncpu);
	self->compress_start = 0;
}

dtrace:::END
{
	printa(@cpu); printa(@totals);
}
