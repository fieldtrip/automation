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
CURL=/usr/bin/curl

BASEDIR=$HOME/fieldtrip/release
TRUNK=$BASEDIR/fieldtrip

cd $TRUNK && git checkout release && git pull upstream release

TODAY=$(git log -1 --format=%cd --date=short | tr -d -)
REVISION=$(cd $TRUNK && git rev-parse --short HEAD)
BRANCH=$(cd $TRUNK && git rev-parse --abbrev-ref HEAD)

cd $BASEDIR || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/                     release-ftp    || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/fileio/              release-fileio || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/qsub/                release-qsub   || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/realtime/src/buffer/ release-buffer || exit 1

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

  mv release-buffer buffer-$TODAY
  $ZIP -r daily/buffer-$TODAY.zip buffer-$TODAY
  mv buffer-$TODAY release-buffer

  # put all daily versions in place on the ftp server
  cp daily/fieldtrip-$TODAY.zip       /home/common/matlab/fieldtrip/data/ftp
  cp daily/fieldtrip-lite-$TODAY.zip  /home/common/matlab/fieldtrip/data/ftp
  cp daily/fileio-$TODAY.zip          /home/common/matlab/fieldtrip/data/ftp/modules
  cp daily/qsub-$TODAY.zip            /home/common/matlab/fieldtrip/data/ftp/modules
  cp daily/buffer-$TODAY.zip          /home/common/matlab/fieldtrip/data/ftp/modules

  # Tweet about it using (sendweet.sh)
  ./sendtweet "A New fieldtrip version "$TODAY" is out! Make sure you have our latest and finest :) "

  # tag it, this autmatically results in a release on github
  cd $TRUNK && git tag $TODAY && git push upstream --tags

  # push it to the EEGLAB ftp server
  $CURL -T $BASEDIR/daily/fileio-$TODAY.zip         ftp://sccn.ucsd.edu/incoming/
  $CURL -T $BASEDIR/daily/fieldtrip-lite-$TODAY.zip ftp://sccn.ucsd.edu/incoming/

  # notify Arno that new plugin versions are available for inclusion in EEGLAB
  $CURL "https://sccn.ucsd.edu/eeglab/plugin_uploader/update_donders.php?file=fileio-$TODAY.zip&version=$TODAY&name=Fileio"
  $CURL "https://sccn.ucsd.edu/eeglab/plugin_uploader/update_donders.php?file=fieldtrip-lite-$TODAY.zip&version=$TODAY&name=Fieldtrip-lite"
fi
