#!/usr/bin/env bash

LOGDIR=$HOME/fieldtrip/dashboard/logs

cd $LOGDIR

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls

# determine the latest version that ran
LATEST=`$LS -al latest | $AWK '{print $NF}'`

if ( $GREP --silent FAILED $LATEST/*.txt ) ; then
  $GREP FAILED $LATEST/*.txt | mail -r r.oostenveld@donders.ru.nl -s "FAILED test in latest FieldTrip batch" r.oostenveld@donders.ru.nl,j.schoffelen@donders.ru.nl
fi
