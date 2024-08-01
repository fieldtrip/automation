#!/bin/bash

echo Executing $0

# specify working directories
PROJECTDIR=/project/3011231.02/
EXTERNALDIR=$PROJECTDIR/fieldtrip/external
FIELDTRIPDIR=$PROJECTDIR/fieldtrip/fieldtrip

LOGFILE=$PROJECTDIR/fieldtrip/external.log

cd $FIELDTRIPDIR && git checkout master && git pull upstream master

cd $EXTERNALDIR  || exit
for TOOLBOX in `ls` ; do
  if [ ! -z "$TOOLBOX" ]; then
    Updating $TOOLBOX ...
    cd $EXTERNALDIR/$TOOLBOX
    git pull
    rsync -arpv --exclude .git $EXTERNALDIR/$TOOLBOX/ $FIELDTRIPDIR/external/$TOOLBOX/
  fi
done

cd $FIELDTRIPDIR || exit
git commit -am "automatically updated external toolboxes"
git push upstream master

date > $LOGFILE
