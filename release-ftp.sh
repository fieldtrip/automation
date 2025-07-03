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
ZIP=/usr/bin/zip
CURL=/usr/bin/curl
SCP=/usr/bin/scp
RSYNC=/usr/bin/rsync

# specify working directories
PROJECTDIR=/project/3031000.02
FIELDTRIPDIR=$PROJECTDIR/fieldtrip
RELEASEDIR=$PROJECTDIR/release
FTPDIR=$PROJECTDIR/external/download

cd $FIELDTRIPDIR && git checkout release && git pull upstream release

TODAY=$(git log -1 --format=%cd --date=short | tr -d -)
REVISION=$(cd $FIELDTRIPDIR && git rev-parse --short HEAD)
BRANCH=$(cd $FIELDTRIPDIR && git rev-parse --abbrev-ref HEAD)

cd $RELEASEDIR || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $FIELDTRIPDIR/                     $RELEASEDIR/release-ftp    || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $FIELDTRIPDIR/fileio/              $RELEASEDIR/release-fileio || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $FIELDTRIPDIR/qsub/                $RELEASEDIR/release-qsub   || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $FIELDTRIPDIR/realtime/src/buffer/ $RELEASEDIR/release-buffer || exit 1

LASTREVISION=$(cat revision)
echo Last revision is $LASTREVISION
if [[ "x$REVISION" = "x$LASTREVISION" ]]
then
  echo the current release has not been updated compared to the previous
  exit 0
else
  echo the current release is an updated version
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
  cp daily/fieldtrip-$TODAY.zip       $FTPDIR
  cp daily/fieldtrip-lite-$TODAY.zip  $FTPDIR
  cp daily/fileio-$TODAY.zip          $FTPDIR/modules
  cp daily/qsub-$TODAY.zip            $FTPDIR/modules
  cp daily/buffer-$TODAY.zip          $FTPDIR/modules

  # tag it, this autmatically results in a release on github
  cd $FIELDTRIPDIR && git tag $TODAY && git push upstream --tags

fi

