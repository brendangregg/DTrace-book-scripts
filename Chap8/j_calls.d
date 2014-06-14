#!/usr/sbin/dtrace -Zs
/*
 * j_calls.d
 *
 * Example script from Chapter 8 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

hotspot*:::method-entry
{
	this->class = (char *)copyin(arg1, arg2 + 1);
	this->class[arg2] = '\0';
	this->method = (char *)copyin(arg3, arg4 + 1);
	this->method[arg4] = '\0';
	this->name = strjoin(strjoin(stringof(this->class), "."),
	    stringof(this->method));
	@calls[pid, "method", this->name] = count();
}

hotspot*:::object-alloc
{
	this->class = (char *)copyin(arg1, arg2 + 1);
	this->class[arg2] = '\0';
	@calls[pid, "oalloc", stringof(this->class)] = count();
}

hotspot*:::class-loaded
{
	this->class = (char *)copyin(arg0, arg1 + 1);
	this->class[arg1] = '\0';
	@calls[pid, "cload", stringof(this->class)] = count();
}

hotspot*:::thread-start
{
	this->thread = (char *)copyin(arg0, arg1 + 1);
	this->thread[arg1] = '\0';
	@calls[pid, "thread", stringof(this->thread)] = count();
}

hotspot*:::method-compile-begin
{
	this->class = (char *)copyin(arg0, arg1 + 1);
	this->class[arg1] = '\0';
	this->method = (char *)copyin(arg2, arg3 + 1);
	this->method[arg3] = '\0';
	this->name = strjoin(strjoin(stringof(this->class), "."),
	    stringof(this->method));
	@calls[pid, "mcompile", this->name] = count();
}

hotspot*:::compiled-method-load
{
	this->class = (char *)copyin(arg0, arg1 + 1);
	this->class[arg1] = '\0';
	this->method = (char *)copyin(arg2, arg3 + 1);
	this->method[arg3] = '\0';
	this->name = strjoin(strjoin(stringof(this->class), "."),
	    stringof(this->method));
	@calls[pid, "mload", this->name] = count();
}

dtrace:::END
{
	printf(" %6s %-8s %-52s %8s\n", "PID", "TYPE", "NAME", "COUNT");
	printa(" %6d %-8s %-52s %@8d\n", @calls);
}
