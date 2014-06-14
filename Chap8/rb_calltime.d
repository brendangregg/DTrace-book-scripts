#!/usr/sbin/dtrace -Zs
/*
 * rb_calltime.d
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

ruby*:::function-entry
{
	self->depth++;
	self->exclude[self->depth] = 0;
	self->function[self->depth] = timestamp;
}

ruby*:::function-return
/self->function[self->depth]/
{
	this->elapsed_incl = timestamp - self->function[self->depth];
	this->elapsed_excl = this->elapsed_incl - self->exclude[self->depth];
	self->function[self->depth] = 0;
	self->exclude[self->depth] = 0;
	this->file = basename(copyinstr(arg2));
	this->name = strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1));

	@num[this->file, "func", this->name] = count();
	@num["-", "total", "-"] = count();
	@types_incl[this->file, "func", this->name] = sum(this->elapsed_incl);
	@types_excl[this->file, "func", this->name] = sum(this->elapsed_excl);
	@types_excl["-", "total", "-"] = sum(this->elapsed_excl);

	self->depth--;
	self->exclude[self->depth] += this->elapsed_incl;
}

ruby*:::object-create-start
{
	self->object = timestamp;
}

ruby*:::object-create-done
/self->object/
{
	this->elapsed = timestamp - self->object;
	self->object = 0;
	this->file = basename(copyinstr(arg1));
	this->file = this->file != NULL ? this->file : ".";
	this->name = copyinstr(arg0);

	@num[this->file, "obj-new", this->name] = count();
	@types[this->file, "obj-new", this->name] = sum(this->elapsed);

	self->exclude[self->depth] += this->elapsed;
}

ruby*:::gc-begin
{
	self->gc = timestamp;
}

ruby*:::gc-end
/self->gc/
{
	this->elapsed = timestamp - self->gc;
	self->gc = 0;
	@num[".", "gc", "-"] = count();
	@types[".", "gc", "-"] = sum(this->elapsed);
	self->exclude[self->depth] += this->elapsed;
}

dtrace:::END
{
	printf("\nCount,\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "COUNT");
	printa("   %-20s %-10s %-32s %@8d\n", @num);

	normalize(@types, 1000);
	printf("\nElapsed times (us),\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "TOTAL");
	printa("   %-20s %-10s %-32s %@8d\n", @types);

	normalize(@types_excl, 1000);
	printf("\nExclusive function elapsed times (us),\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "TOTAL");
	printa("   %-20s %-10s %-32s %@8d\n", @types_excl);

	normalize(@types_incl, 1000);
	printf("\nInclusive function elapsed times (us),\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "TOTAL");
	printa("   %-20s %-10s %-32s %@8d\n", @types_incl);
}
