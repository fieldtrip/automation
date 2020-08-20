#!/bin/bash
#
# This script makes a changelog entry from the git commits, comparing
# the latest tag/release to the one before.
#

TRUNK=$HOME/fieldtrip/fieldtrip

cd $TRUNK || exit 1

CURRENT=`git tag | grep 20..... | sort | tail -1`
PREVIOUS=`git tag | grep 20..... | sort | tail -2 | head -1`

git log --oneline $PREVIOUS...$CURRENT

