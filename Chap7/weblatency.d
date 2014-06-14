#!/usr/sbin/dtrace -s
/*
 * weblatency.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet

/* browser's execname */
inline string BROWSER = "mozilla-bin";

/* maximum expected hostname length + "GET http://" */
inline int MAX_REQ = 64;

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

/*
 * Trace brower request
 *
 * This is achieved by matching writes for the browser's execname that
 * start with "GET", and then timing from the return of the write to
 * the return of the next read in the same thread. Various stateful flags
 * are used: self->fd, self->read.
 *
 * For performance reasons, I'd like to only process writes that follow a
 * connect(), however this approach fails to process keepalives.
 */
syscall::write:entry
/execname == BROWSER/
{
	self->buf = arg1;
	self->fd = arg0 + 1;
	self->nam = "";
}

syscall::write:return
/self->fd/
{
	this->str = (char *)copyin(self->buf, MAX_REQ);
	this->str[4] = '\0';
	self->fd = stringof(this->str) == "GET " ? self->fd : 0;
}

syscall::write:return
/self->fd/
{
	/* fetch browser request */
	this->str = (char *)copyin(self->buf, MAX_REQ);
	this->str[MAX_REQ] = '\0';

	/*
	 * This unrolled loop strips down a URL to it's hostname.
	 * We ought to use strtok(), but it's not available on Sol 10 3/05,
	 * so instead I used dirname(). It's not pretty - it's done so that
	 * this works on all Sol 10 versions.
	 */
	self->req = stringof(this->str);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->req = dirname(self->req);
	self->nam = strlen(self->req) > 15 ? self->req : self->nam;
	self->nam = basename(self->nam);

	/* start the timer */
	start[pid, self->fd - 1] = timestamp;
	host[pid, self->fd - 1] = self->nam;
	self->buf = 0;
	self->fd  = 0;
	self->req = 0;
	self->nam = 0;
}

/* this one wasn't a GET */
syscall::write:return
/self->buf/
{
	self->buf = 0;
	self->fd  = 0;
}

syscall::read:entry
/execname == BROWSER && start[pid, arg0]/
{
	self->fd = arg0 + 1;
}

/*
 * Record host details
 */
syscall::read:return
/self->fd/
{
	/* fetch details */
	self->host = stringof(host[pid, self->fd - 1]);
	this->start = start[pid, self->fd - 1];

	/* save details */
	@Avg[self->host] = avg((timestamp - this->start)/1000000);
	@Max[self->host] = max((timestamp - this->start)/1000000);
	@Num[self->host] = count();

	/* clear vars */
	start[pid, self->fd - 1] = 0;
	host[pid, self->fd - 1] = 0;
	self->host = 0;
	self->fd = 0;
}

/*
 * Output report
 */
dtrace:::END
{
	printf("%-32s %11s\n", "HOST", "NUM");
	printa("%-32s %@11d\n", @Num);

	printf("\n%-32s %11s\n", "HOST", "AVGTIME(ms)");
	printa("%-32s %@11d\n", @Avg);

	printf("\n%-32s %11s\n", "HOST", "MAXTIME(ms)");
	printa("%-32s %@11d\n", @Max);
}
