#!/usr/bin/env bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb

# make it robust for running as a cron job
AWK=/usr/bin/awk
GIT=/usr/bin/git
GREP=/usr/bin/grep
LS=/usr/bin/ls
MAIL=/usr/bin/mail
RSYNC=/opt/cluster/external/utilities/bin64/rsync
ZIP=/usr/bin/zip

TRUNK=$HOME/fieldtrip/release/fieldtrip

cd $TRUNK && $GIT checkout release && $GIT pull upstream release

cd $HOME/fieldtrip/release || exit 1
$RSYNC -ar --copy-links --delete --exclude .git $TRUNK/ release-nijmegen || exit 1
# find . -type f -exec chmod 644 {} \;
# find . -type d -exec chmod 755 {} \;

# update the home/common version
$RSYNC -ar --delete --exclude data $HOME/fieldtrip/release/release-nijmegen/ /home/common/matlab/fieldtrip || exit 1

