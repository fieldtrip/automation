#!/usr/bin/env bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb

TODAY=$(date +%Y%m%d)
BASEDIR=$HOME/fieldtrip/release
TRUNK=$BASEDIR/fieldtrip
MD5FILE=$BASEDIR/.tarmd5-release-ftp

cd $TRUNK && git pull upstream master

cd $BASEDIR || exit 1

rsync -ar --copy-links --delete --exclude .git --exclude test $TRUNK/ release-ftp || exit 1

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
	zip -r daily/fieldtrip-$TODAY.zip fieldtrip-$TODAY
	zip -r daily/fieldtrip-lite-$TODAY.zip fieldtrip-$TODAY -x@exclude.lite
	mv fieldtrip-$TODAY release-ftp
	
	cp daily/fieldtrip-$TODAY.zip      /home/common/matlab/fieldtrip/data/ftp/fieldtrip-$TODAY.zip
	cp daily/fieldtrip-lite-$TODAY.zip /home/common/matlab/fieldtrip/data/ftp/fieldtrip-lite-$TODAY.zip
fi
