#!/usr/sbin/dtrace -s
/*
 * httpdurls.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

inline string WEB_SERVER_PROCESS_NAME = "httpd";

dtrace:::BEGIN
{
	printf("Tracing GET from %s processes... Hit Ctrl-C to end.\n",
	    WEB_SERVER_PROCESS_NAME);
}

syscall::read:entry
/execname == WEB_SERVER_PROCESS_NAME/
{
	self->buf = arg1;
}

syscall::read:return
/self->buf && arg1 > 10/
{
	this->req = (char *)copyin(self->buf, arg1);
	this->get = strstr(this->req, "GET") != NULL;
}

syscall::read:return
/self->buf && this->get/
{
	this->line = strtok(this->req, "\r");
	this->word0 = this->line != NULL ? strtok(this->line, " ") : "";
	this->word1 = this->line != NULL ? strtok(NULL, " ") : "";
	this->word2 = this->line != NULL ? strtok(NULL, " ") : "";
}

syscall::read:return
/this->word0 != NULL && this->word1 != NULL && this->word2 != NULL &&
	this->word0 == "GET"/
{
	@[stringof(this->word2), stringof(this->word1)] = count();
}

syscall::read:return
{
	self->buf = 0;
}

dtrace:::END
{
	printf("  %-10s %-54s %10s\n", "PROTOCOL", "URL", "COUNT");
	printa("  %-10s %-54s %@10d\n", @);
}
