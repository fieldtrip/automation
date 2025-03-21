#!/usr/bin/env bash
#
# Execute the batch of FieldTrip test scripts on the DCCN linux cluster.
#
# This uses a cript that is in https://github.com/fieldtrip/dashboard, which is started like this
#   schedule-batch.sh <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#   schedule-batch.sh <FIELDTRIPDIR> <LOGDIR>
#   schedule-batch.sh <FIELDTRIPDIR>

echo Executing $0

# specify working directories
PROJECTDIR=/project/3031000.02
DASHBOARDDIR=$PROJECTDIR/dashboard
FIELDTRIPDIR=$PROJECTDIR/fieldtrip

cd $FIELDTRIPDIR && git checkout master && git pull upstream master

$DASHBOARDDIR/schedule-batch.sh $FIELDTRIPDIR

