#!/bin/bash

# this script is not executed by a webhook, but rather by a cronjob

FILEPATH=`dirname "$0"`
CMDFILE=`basename "$0" .sh`
LOGFILE="$FILEPATH"/"$CMDFILE".log
FIELDTRIPDIR=$HOME/fieldtrip/fieldtrip
EXTERNALDIR=$HOME/fieldtrip/external

date > $LOGFILE

cd $EXTERNALDIR
for TOOLBOX in * ; do
  cd $TOOLBOX 
  git pull 
  echo rsync -arpv --exclude .git $EXTERNALDIR/$TOOLBOX/ $FIELDTRIPDIR/external/$TOOLBOX/
  cd $EXTERNALDIR
done

cd $FIELDTRIPDIR
git commit -am "automatically updated external toolboxes"
git push

