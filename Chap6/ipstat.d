#!/usr/sbin/dtrace -s
/*
 * ipstat.d
 *
 * Example script from Chapter 6 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	LINES = 20; line = 0;
}

profile:::tick-1sec
/--line <= 0/
{
	printf("  IP IF:  %12s %12s %12s %12s %12s\n", "out(bytes)",
	    "outDiscards", "in(bytes)", "inDiscards", "inErrors");
	line = LINES;
}

mib:::ipIfStatsHCInOctets       { @in = sum(arg0);      }
mib:::ipIfStatsHCOutOctets      { @out = sum(arg0);     }
mib:::ipIfStatsInDiscards       { @inDis = sum(arg0);   }
mib:::ipIfStatsOutDiscards      { @outDis = sum(arg0);  }
mib:::ipIfStatsIn*Errors        { @inErr = sum(arg0);   }

profile:::tick-1sec
{
	printa("          %@12d %@12d %@12d %@12d %@12d\n",
	    @out, @outDis, @in, @inDis, @inErr);
	clear(@out); clear(@outDis); clear(@in); clear(@inDis); clear(@inErr);
}
