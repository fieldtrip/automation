#!/usr/bin/env bash
#
# This script checks whether all tests passed in the latest batch,
# and then merges the master with the release branch.
#
# Use as
#   dashboard-release.sh
# to check and merge the latest revision that was executed, or
#   dashboard-release.sh <REVISION>
# for a specific revision.
#

echo Executing $0

# make it robust for running as a cron job
AWK=/usr/bin/awk
GIT=/usr/bin/git
GREP=/usr/bin/grep
LS=/usr/bin/ls
MAIL=/usr/bin/mail
RSYNC=/opt/cluster/external/utilities/bin64/rsync

# specify working directories
PROJECTDIR=/home/megmethods/roboos
DASHBOARDDIR=$PROJECTDIR/fieldtrip/dashboard
FIELDTRIPDIR=$PROJECTDIR/fieldtrip/fieldtrip

REVISION=$1

if [ -z "$REVISION" ] ; then
# determine the revision of the latest version that ran
REVISION=$(cat $DASHBOARDDIR/logs/latest/revision)
fi

# stop here if the revision cannot be determined
[ -z "$REVISION" ] && exit 1

LOGDIR=$DASHBOARDDIR/logs/$REVISION
BRANCH=$(cat $LOGDIR/branch)
FAILED=$($GREP FAILED $LOGDIR/*.txt | wc -l)
PASSED=$($GREP PASSED $LOGDIR/*.txt | wc -l)

if [ "$BRANCH" == "master" ]; then
if [ $FAILED -eq 0 ]; then
if [ $PASSED -gt 600 ]; then

echo merging $LATEST into release

cd $FIELDTRIPDIR && $GIT checkout master && $GIT pull upstream master && $GIT checkout release
$GIT log -1 $REVISION || exit 1
$GIT merge $REVISION
$GIT push upstream release

fi
fi
fi

