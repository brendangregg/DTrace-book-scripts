#!/usr/sbin/dtrace -s
/*
 * tcpstat.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN                  { LINES = 20; line = 0; }

profile:::tick-1sec
/--line <= 0/
{
	printf("  TCP bytes:  %6s %12s %12s %12s %12s\n",
	    "out", "outRetrans", "in", "inDup", "inUnorder");
	line = LINES;
}
mib:::tcpOutDataBytes, mib:::tcpRetransBytes, mib:::tcpInDataInorderBytes,
mib:::tcpInDataDupBytes, mib:::tcpInDataUnorderBytes
{
	/* some of these probes can return -1 */
	this->bytes = (int)arg0 > 0 ? arg0 : 0;
}

mib:::tcpOutDataBytes           { @out = sum(this->bytes);   }
mib:::tcpRetransBytes           { @outRe = sum(this->bytes); }
mib:::tcpInDataInorderBytes     { @in = sum(this->bytes);    }
mib:::tcpInDataDupBytes         { @inDup = sum(this->bytes); }
mib:::tcpInDataUnorderBytes     { @inUn = sum(this->bytes);  }

profile:::tick-1sec
{
	printa("        %@12d %@12d %@12d %@12d %@12d\n",
	    @out, @outRe, @in, @inDup, @inUn);
	clear(@out); clear(@outRe); clear(@in); clear(@inDup); clear(@inUn);
}
