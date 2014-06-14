dtrace -n 'proc:::exec-success { trace(curpsinfo->pr_psargs); }'
