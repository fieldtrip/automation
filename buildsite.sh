#!/bin/bash

FILEPATH=`dirname "$0"`
CMDFILE=`basename "$0" .sh`
LOGFILE="$FILEPATH"/"$CMDFILE".log
WEBSITEDIR=$HOME/fieldtrip/website

cd $WEBSITEDIR
date                                                 > $LOGFILE
echo START                                          >> $LOGFILE
git pull                                            >> $LOGFILE
jekyll build                                        >> $LOGFILE
rsync -arpv --delete _site buildsite@whitepi.local: >> $LOGFILE
echo DONE                                           >> $LOGFILE
date                                                >> $LOGFILE

