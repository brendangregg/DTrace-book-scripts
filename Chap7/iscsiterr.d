#!/usr/sbin/dtrace -Cs
/*
 * iscsiterr.d
 *
 * Example script from Chapter 7 of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
 * 
 * See the book for the script description and warnings. Many of these are
 * provided as example solutions, and will need changes to work on your OS.
 */

#pragma D option quiet
#pragma D option switchrate=10hz

typedef enum idm_status {
	IDM_STATUS_SUCCESS = 0,
	IDM_STATUS_FAIL,
	IDM_STATUS_NORESOURCES,
	IDM_STATUS_REJECT,
	IDM_STATUS_IO,
	IDM_STATUS_ABORTED,
	IDM_STATUS_SUSPENDED,
	IDM_STATUS_HEADER_DIGEST,
	IDM_STATUS_DATA_DIGEST,
	IDM_STATUS_PROTOCOL_ERROR,
	IDM_STATUS_LOGIN_FAIL
} idm_status_t;

dtrace:::BEGIN
{
	status[IDM_STATUS_FAIL] = "FAIL";
	status[IDM_STATUS_NORESOURCES] = "NORESOURCES";
	status[IDM_STATUS_REJECT] = "REJECT";
	status[IDM_STATUS_IO] = "IO";
	status[IDM_STATUS_ABORTED] = "ABORTED";
	status[IDM_STATUS_SUSPENDED] = "SUSPENDED";
	status[IDM_STATUS_HEADER_DIGEST] = "HEADER_DIGEST";
	status[IDM_STATUS_DATA_DIGEST] = "DATA_DIGEST";
	status[IDM_STATUS_PROTOCOL_ERROR] = "PROTOCOL_ERROR";
	status[IDM_STATUS_LOGIN_FAIL] = "LOGIN_FAIL";

	printf("%-20s  %-20s %s\n", "TIME", "CLIENT", "ERROR");
}

fbt::idm_pdu_complete:entry
/arg1 != IDM_STATUS_SUCCESS/
{
	this->ic = args[0]->isp_ic;
	this->remote = (this->ic->ic_raddr.ss_family == AF_INET) ?
	    inet_ntoa((ipaddr_t *)&((struct sockaddr_in *)&
	this->ic->ic_raddr)->sin_addr) :
	    inet_ntoa6(&((struct sockaddr_in6 *)&
	this->ic->ic_raddr)->sin6_addr);

	this->err = status[arg1] != NULL ? status[arg1] : lltostr(arg1);
	printf("%-20Y  %-20s %s\n", walltimestamp, this->remote, this->err);
}
