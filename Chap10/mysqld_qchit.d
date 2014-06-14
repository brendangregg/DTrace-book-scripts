#!/usr/sbin/dtrace -s
/*
 * mysqld_qchit.d
 *
 * Example script from Chapter 10 of the book: DTrace: Dynamic Tracing in
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
	hits = 0; misses = 0;
}

mysql*:::query-cache-hit,
mysql*:::query-cache-miss
{
	this->query = copyinstr(arg0);
}

mysql*:::query-cache-hit,
mysql*:::query-cache-miss
/strlen(this->query) > 60/
{
	this->query[57] = '.';
	this->query[58] = '.';
	this->query[59] = '.';
	this->query[60] = 0;
}

mysql*:::query-cache-hit
{
	@cache[this->query, "hit"] = count();
	hits++;
}

mysql*:::query-cache-miss
{
	@cache[this->query, "miss"] = count();
	misses++;
}

dtrace:::END
{
	printf("   %-60s %6s %6s\n", "QUERY", "RESULT", "COUNT");
	printa("   %-60s %6s %@6d\n", @cache);
	total = hits + misses;
	printf("\nHits     : %d\n", hits);
	printf("Misses   : %d\n", misses);
	printf("Hit Rate : %d%%\n", total ? (hits * 100) / total : 0);
}
