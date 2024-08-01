#!/usr/bin/env bash

echo Executing $0

# specify working directories
PROJECTDIR=/project/3011231.02/
FIELDTRIPDIR=$PROJECTDIR/fieldtrip/fieldtrip
FILEIODIR=$PROJECTDIR/fieldtrip/fileio
QSUBDIR=$PROJECTDIR/fieldtrip/qsub

LOGFILE=$PROJECTDIR/fieldtrip/github.log

# get all changes from the master branch on github
cd $FIELDTRIPDIR || exit
git checkout master
git pull upstream master

# synchronize identical files
# if there are no changes, this will give "nothing to commit, working directory clean"
REV=`git log -n 1 --pretty=format:"%H"`
$FIELDTRIPDIR/bin/synchronize-private.sh
git commit -a -m "automatically synchronized identical files to $REV"
git push upstream master

# also push to bitbucket
git push bitbucket master

# also push to gitlab
git push gitlab master

# synchronize the fileio repository
cd $FILEIODIR || exit
rsync -arp --delete --exclude '.git' $FIELDTRIPDIR/fileio/* .
git add .
git commit -am "synchronized with main FieldTrip repository"
git push

# synchronize the qsub repository
cd $QSUBDIR || exit
rsync -arp --delete --exclude '.git' $FIELDTRIPDIR/qsub/* .
git add .
git commit -am "synchronized with main FieldTrip repository"
git push

date > $LOGFILE
