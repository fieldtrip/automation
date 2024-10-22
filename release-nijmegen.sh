#!/usr/bin/env bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb

echo Executing $0

# make it robust for running as a cron job
AWK=/usr/bin/awk
GIT=/usr/bin/git
GREP=/usr/bin/grep
LS=/usr/bin/ls
MAIL=/usr/bin/mail
RSYNC=/opt/cluster/external/utilities/bin64/rsync
ZIP=/usr/bin/zip

# specify working directories
PROJECTDIR=/home/megmethods/roboos
FIELDTRIPDIR=$PROJECTDIR/fieldtrip/fieldtrip
RELEASEDIR=$PROJECTDIR/fieldtrip/release
NIJMEGENDIR=/home/common/matlab/fieldtrip

cd $FIELDTRIPDIR && $GIT checkout release && $GIT pull upstream release

cd $RELEASEDIR || exit 1
$RSYNC -ar --copy-links --delete --exclude .git $FIELDTRIPDIR/ $RELEASEDIR/release-nijmegen || exit 1
# find . -type f -exec chmod 644 {} \;
# find . -type d -exec chmod 755 {} \;

# update the version on the shared directory
$RSYNC -ar --delete --exclude data $RELEASEDIR/release-nijmegen/ $NIJMEGENDIR || exit 1

