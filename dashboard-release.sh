#!/usr/bin/env bash
#
# This script checks whether all tests passed in the latest batch,
# and then merges the master with the release branch.

TRUNK=$HOME/fieldtrip/release/fieldtrip
LOGDIR=$HOME/fieldtrip/dashboard/logs

cd $LOGDIR

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls
GIT=/usr/bin/git

# determine the latest version that ran
LATEST=`$LS -al latest | $AWK '{print $NF}'`
BRANCH=$(cat $LATEST/branch)
FAILED=$($GREP FAILED $LATEST/*.txt | wc -l)
PASSED=$($GREP PASSED $LATEST/*.txt | wc -l)

if [ "$BRANCH" == "master" ]; then
# echo $BRANCH
if [ $PASSED -gt 600 ]; then
# echo $PASSED
if [ $FAILED -eq 0 ]; then
# echo $FAILED

echo merging $LATEST into release
cd $TRUNK && $GIT pull upstream release
$GIT merge $LATEST && $GIT push upstream release

fi
fi
fi

