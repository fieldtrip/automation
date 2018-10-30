#!/bin/bash

FILEPATH=`dirname "$0"`
CMDFILE=`basename "$0" .sh`
LOGFILE="$FILEPATH"/"$CMDFILE".log
WEBSITEDIR=$HOME/fieldtrip/website

date > $LOGFILE

cd $WEBSITEDIR
git pull
jekyll build
rsync -arpv --delete _site buildsite@whitepi.local:
