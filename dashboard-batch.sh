#!/usr/bin/env bash
#
# Execute the batch of FieldTrip test scripts on the DCCN linux cluster.
#
# This uses a cript that is in https://github.com/fieldtrip/dashboard, which is started like this
#   schedule-tests.sh <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#   schedule-tests.sh <FIELDTRIPDIR> <LOGDIR>
#   schedule-tests.sh <FIELDTRIPDIR>

DASHBOARDDIR=$HOME/fieldtrip/dashboard
TRUNK=$HOME/fieldtrip/release/fieldtrip

$DASHBOARDDIR/schedule-tests.sh $TRUNK

