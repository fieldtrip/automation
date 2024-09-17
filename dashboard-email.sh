#!/usr/bin/env bash

echo Executing $0

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls
CHMOD=/usr/bin/chmod

# specify working directories
PROJECTDIR=/project/3011231.02/
DASHBOARDDIR=$PROJECTDIR/fieldtrip/dashboard
LOGDIR=$DASHBOARDDIR/logs

# allow other team members to read the log files
$CHMOD 644 $LOGDIR/latest/*

cd $LOGDIR || exit

# determine the latest version that ran
LATEST=`$LS -al latest | $AWK '{print $NF}'`

if ( $GREP --silent FAILED $LATEST/*.txt ) ; then
  $GREP FAILED $LATEST/*.txt | mail -r r.oostenveld@donders.ru.nl -s "FAILED tests in latest FieldTrip batch" r.oostenveld@donders.ru.nl,j.schoffelen@donders.ru.nl
fi
