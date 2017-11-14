#!/bin/sh

FILEPATH=`dirname "$0"`
CMDFILE=`basename "$0" .sh`
LOGFILE="$FILEPATH"/"$CMDFILE".log
FIELDTRIPDIR=$HOME/fieldtrip/fieldtrip

date > $LOGFILE

# get all changes from the master branch on github
cd $FIELDTRIPDIR
git checkout master
git pull origin master

# synchronize identical files
# if there are no changes, this will give "nothing to commit, working directory clean"
REV=`git log -n 1 --pretty=format:"%H"`
$FIELDTRIPDIR/bin/synchronize-private.sh
git commit -a -m "automatically synchronized identical files to $REV"
git push origin master

# also push to bitbucket
git push bitbucket master

# also push to gitlab
git push gitlab master

