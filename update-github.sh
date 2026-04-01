#!/usr/bin/env bash

echo Executing $0

# specify working directories
PROJECTDIR=/project/3031000.02
FIELDTRIPDIR=$PROJECTDIR/fieldtrip
FILEIODIR=$PROJECTDIR/fileio
QSUBDIR=$PROJECTDIR/qsub

LOGFILE=$PROJECTDIR/github.log

# get all changes from the master branch on github
cd $FIELDTRIPDIR || exit
git checkout master
git pull upstream master

# push to bitbucket
git push bitbucket master

# push to gitlab
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
