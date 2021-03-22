#!/usr/bin/env bash

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls
CHMOD=/usr/bin/chmod

LOGDIR=$HOME/fieldtrip/dashboard/logs

# allow other team members to read the log files
$CHMOD 644 $LOGDIR/latest/*

cd $LOGDIR

# determine the latest version that ran
LATEST=`$LS -al latest | $AWK '{print $NF}'`

if ( $GREP --silent FAILED $LATEST/*.txt ) ; then
  $GREP FAILED $LATEST/*.txt | mail -r r.oostenveld@donders.ru.nl -s "FAILED tests in latest FieldTrip batch" r.oostenveld@donders.ru.nl,j.schoffelen@donders.ru.nl
fi
