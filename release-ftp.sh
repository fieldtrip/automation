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

BASEDIR=$HOME/fieldtrip/release
TRUNK=$BASEDIR/fieldtrip

cd $TRUNK && git checkout release && git pull upstream release

TODAY=$(git log -1 --format=%cd --date=short | tr -d -)
REVISION=$(cd $TRUNK && git rev-parse --short HEAD)
BRANCH=$(cd $TRUNK && git rev-parse --abbrev-ref HEAD)

cd $BASEDIR || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/       release-ftp    || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/fileio release-fileio || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/qsub   release-qsub   || exit 1

LASTREVISION=$(cat revision)
if [[ "x$REVISION" = "x$LASTREVISION" ]]
then
  # the current release has not been updated compared to the previous
  exit 0
else
  # the current release is an updated version
  echo $REVISION > revision

  # remove all older versions
  rm daily/*.zip

  mv release-ftp fieldtrip-$TODAY
  $ZIP -r daily/fieldtrip-$TODAY.zip fieldtrip-$TODAY
  $ZIP -r daily/fieldtrip-lite-$TODAY.zip fieldtrip-$TODAY -x@exclude.lite
  mv fieldtrip-$TODAY release-ftp

  mv release-fileio fileio-$TODAY
  $ZIP -r daily/fileio-$TODAY.zip fileio-$TODAY
  mv fileio-$TODAY release-fileio

  mv release-qsub qsub-$TODAY
  $ZIP -r daily/qsub-$TODAY.zip qsub-$TODAY
  mv qsub-$TODAY release-qsub

  # put all daily versions in place on the ftp server
  cp daily/fieldtrip-$TODAY.zip       /home/common/matlab/fieldtrip/data/ftp
  cp daily/fieldtrip-lite-$TODAY.zip  /home/common/matlab/fieldtrip/data/ftp
  cp daily/fileio-$TODAY.zip          /home/common/matlab/fieldtrip/data/ftp/modules
  cp daily/qsub-$TODAY.zip            /home/common/matlab/fieldtrip/data/ftp/modules

  # tag it, this autmatically results in a release on github
  cd $TRUNK && git tag $TODAY && git push upstream --tags

  # push it to the EEGLAB ftp server
  curl -T daily/fileio-$TODAY.zip         ftp://sccn.ucsd.edu/incoming/
  curl -T daily/fieldtrip-lite-$TODAY.zip ftp://sccn.ucsd.edu/incoming/

  # notify Arno that new plugin versions are available for inclusion in EEGLAB
  curl -X get "http://sccn.ucsd.edu/plugin_uploader/update_donders.php?file=fileio-20190618.zip&version=$TODAY&name=fileio"
  curl -X get "http://sccn.ucsd.edu/plugin_uploader/update_donders.php?file=fieldtrip-lite-20190618.zip&version=$TODAY&name=fieldtrip-lite"
fi

