#!/usr/bin/env bash
#
# Execute the batch of FieldTrip test scripts on the DCCN linux cluster.
#
# This uses a cript that is in https://github.com/fieldtrip/dashboard, which is started like this
#   schedule-batch.sh <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#   schedule-batch.sh <FIELDTRIPDIR> <LOGDIR>
#   schedule-batch.sh <FIELDTRIPDIR>

DASHBOARDDIR=$HOME/fieldtrip/dashboard
TRUNK=$HOME/fieldtrip/release/fieldtrip

$DASHBOARDDIR/schedule-batch.sh $TRUNK

