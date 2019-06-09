#!/usr/bin/env bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb

TRUNK=$HOME/fieldtrip/release/fieldtrip

cd $TRUNK && git checkout release && git pull upstream release

cd $HOME/fieldtrip/release || exit 1
rsync -ar --copy-links --delete --exclude .git $TRUNK/ release-nijmegen || exit 1
# find . -type f -exec chmod 644 {} \;
# find . -type d -exec chmod 755 {} \;

# update the home/common version
rsync -ar --delete --exclude data $HOME/fieldtrip/release/release-nijmegen/ /home/common/matlab/fieldtrip || exit 1

