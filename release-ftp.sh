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
MD5FILE=$BASEDIR/.tarmd5-release-ftp

cd $TRUNK && git checkout release && git pull upstream release

# TODAY=$(date +%Y%m%d)
# TODAY=$(git log -1 --format=%cd --date=format:%Y%m%d)
TODAY=$(git log -1 --format=%cd --date=short | tr -d -)

cd $BASEDIR || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/ release-ftp || exit 1

CURRMD5=$(tar cf - release-ftp | md5sum |awk '{print $1}')
LASTMD5=$(cat $MD5FILE)
if [[ "x$CURRMD5" = "x$LASTMD5" ]]
then
  # the current release has not been updated compared to the previous
  exit 0
else
  # the current release is an updated version
  echo $CURRMD5 > $MD5FILE

  # remove all older versions
  rm daily/fieldtrip-201?????.zip
  rm daily/fieldtrip-lite-201?????.zip

  mv release-ftp fieldtrip-$TODAY
  $ZIP -r daily/fieldtrip-$TODAY.zip fieldtrip-$TODAY
  $ZIP -r daily/fieldtrip-lite-$TODAY.zip fieldtrip-$TODAY -x@exclude.lite
  mv fieldtrip-$TODAY release-ftp
  
  cp daily/fieldtrip-$TODAY.zip      /home/common/matlab/fieldtrip/data/ftp/fieldtrip-$TODAY.zip
  cp daily/fieldtrip-lite-$TODAY.zip /home/common/matlab/fieldtrip/data/ftp/fieldtrip-lite-$TODAY.zip
  
  cd $TRUNK && git tag $TODAY && git push upstream --tags
fi
