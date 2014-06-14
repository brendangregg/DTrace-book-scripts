#!/usr/sbin/dtrace -CZs
/*
 * j_calltime.d
 *
 * Example script from Chapter 8 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#define	TOP	10		/* default output truncation */
#define	B_FALSE	0

#pragma D option quiet
#pragma D option defaultargs

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
	top = $1 != 0 ? $1 : TOP;
}

hotspot*:::method-entry
{
	self->depth[arg0]++;
	self->exclude[arg0, self->depth[arg0]] = 0;
	self->method[arg0, self->depth[arg0]] = timestamp;
}

hotspot*:::method-return
/self->method[arg0, self->depth[arg0]]/
{
	this->elapsed_incl = timestamp - self->method[arg0, self->depth[arg0]];
	this->elapsed_excl = this->elapsed_incl -
	    self->exclude[arg0, self->depth[arg0]];
	self->method[arg0, self->depth[arg0]] = 0;
	self->exclude[arg0, self->depth[arg0]] = 0;

	this->class = (char *)copyin(arg1, arg2 + 1);
	this->class[arg2] = '\0';
	this->method = (char *)copyin(arg3, arg4 + 1);
	this->method[arg4] = '\0';
	this->name = strjoin(strjoin(stringof(this->class), "."),
	    stringof(this->method));

	@num[pid, "method", this->name] = count();
	@num[0, "total", "-"] = count();
	@types_incl[pid, "method", this->name] = sum(this->elapsed_incl);
	@types_excl[pid, "method", this->name] = sum(this->elapsed_excl);
	@types_excl[0, "total", "-"] = sum(this->elapsed_excl);

	self->depth[arg0]--;
	self->exclude[arg0, self->depth[arg0]] += this->elapsed_incl;
}

hotspot*:::gc-begin
{
	self->gc = timestamp;
	self->full = (boolean_t)arg0;
}

hotspot*:::gc-end
/self->gc/
{
	this->elapsed = timestamp - self->gc;
	self->gc = 0;

	@num[pid, "gc", self->full == B_FALSE ? "GC" : "Full GC"] = count();
	@types[pid, "gc", self->full == B_FALSE ? "GC" : "Full GC"] =
	    sum(this->elapsed);
	self->full = 0;
}

dtrace:::END
{
	trunc(@num, top);
	printf("\nTop %d counts,\n", top);
	printf("   %6s %-10s %-48s %8s\n", "PID", "TYPE", "NAME", "COUNT");
	printa("   %6d %-10s %-48s %@8d\n", @num);

	trunc(@types, top);
	normalize(@types, 1000);
	printf("\nTop %d elapsed times (us),\n", top);
	printf("   %6s %-10s %-48s %8s\n", "PID", "TYPE", "NAME", "TOTAL");
	printa("   %6d %-10s %-48s %@8d\n", @types);

	trunc(@types_excl, top);
	normalize(@types_excl, 1000);
	printf("\nTop %d exclusive method elapsed times (us),\n", top);
	printf("   %6s %-10s %-48s %8s\n", "PID", "TYPE", "NAME", "TOTAL");
	printa("   %6d %-10s %-48s %@8d\n", @types_excl);

	trunc(@types_incl, top);
	normalize(@types_incl, 1000);
	printf("\nTop %d inclusive method elapsed times (us),\n", top);
	printf("   %6s %-10s %-48s %8s\n", "PID", "TYPE", "NAME", "TOTAL");
	printa("   %6d %-10s %-48s %@8d\n", @types_incl);
}
