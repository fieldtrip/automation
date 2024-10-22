#!/bin/bash
#
# This script makes a changelog entry from the git commits, comparing
# the latest tag/release to the one before.
#

echo Executing $0

# make it robust for running as a cron job
AWK=/usr/bin/awk
CAT=/usr/bin/cat
CURL=/usr/bin/curl
GIT=/usr/bin/git
GREP=/usr/bin/grep
HEAD=/usr/bin/head
HUB=$HOME/.conda/envs/hub/bin/hub
LS=/usr/bin/ls
MAIL=/usr/bin/mail
MKTEMP=/usr/bin/mktemp
RSYNC=/opt/cluster/external/utilities/bin64/rsync
SORT=/usr/bin/sort
TAIL=/usr/bin/tail
ZIP=/usr/bin/zip

# specify working directories
PROJECTDIR=/home/megmethods/roboos
FIELDTRIPDIR=$PROJECTDIR/fieldtrip/fieldtrip
WEBSITEDIR=$PROJECTDIR/fieldtrip/website

##############################################################################

cd $FIELDTRIPDIR || exit 1

CURRENT=`$GIT tag | $GREP 20..... | $SORT | $TAIL -1 | $HEAD -1`
PREVIOUS=`$GIT tag | $GREP 20..... | $SORT | $TAIL -2 | $HEAD -1`

YYYY=${CURRENT:0:4}
MM=${CURRENT:4:2}
DD=${CURRENT:6:2}

if [ $MM == 01 ] ; then
MONTH=January
elif [ $MM == 02 ] ; then
MONTH=February
elif [ $MM == 03 ] ; then
MONTH=March
elif [ $MM == 04 ] ; then
MONTH=April
elif [ $MM == 05 ] ; then
MONTH=May
elif [ $MM == 06 ] ; then
MONTH=June
elif [ $MM == 07 ] ; then
MONTH=July
elif [ $MM == 08 ] ; then
MONTH=August
elif [ $MM == 09 ] ; then
MONTH=September
elif [ $MM == 10 ] ; then
MONTH=October
elif [ $MM == 11 ] ; then
MONTH=November
elif [ $MM == 12 ] ; then
MONTH=December
fi

# the  title has the month with the first letter in uppercase, the HTML anchor is all in lowercase
LOWERCASE=`echo $MONTH | sed -e 's/^./\L&\E/'`

TEMPFILE=`$MKTEMP`

$CAT > $TEMPFILE << EOF
---
title: $DD $MONTH $YYYY - FieldTrip version $CURRENT has been released
categories: [release]
tweet: FieldTrip version $CURRENT was just released. See http://www.fieldtriptoolbox.org/#$DD-$LOWERCASE-$YYYY
---

### $DD $MONTH, $YYYY

FieldTrip version [$CURRENT](http://github.com/fieldtrip/fieldtrip/releases/tag/$CURRENT) has been released.
See [GitHub](https://github.com/fieldtrip/fieldtrip/compare/$PREVIOUS...$CURRENT) for the detailed list of updates.

#### Commits

EOF

# use awk to convert it into a list and to add the URL to each commit
$GIT log --oneline $PREVIOUS...$CURRENT | $AWK '$1="- ["$1"](http://github.com/fieldtrip/fieldtrip/commit/"$1")"' >> $TEMPFILE

##############################################################################

# the following uses https://github.com/github/hub
# which is installed using anaconda
# module load anaconda3
# source activate hub

cd $WEBSITEDIR || exit 1

$GIT checkout master
$GIT pull origin master

if [ -e "$WEBSITEDIR/_posts/$YYYY-$MM-$DD-release.md" ] ; then
  echo there is already a news item for this release
  exit 0
fi

$GIT checkout -b $YYYY-$MM-$DD-release
cp $TEMPFILE "$WEBSITEDIR/_posts/$YYYY-$MM-$DD-release.md"
$GIT add "$WEBSITEDIR/_posts/$YYYY-$MM-$DD-release.md"
$GIT commit -am "added news item for release"
$GIT push --set-upstream origin $YYYY-$MM-$DD-release && $HUB pull-request -m "add news item for release $CURRENT"
$GIT checkout master
$GIT branch -D $YYYY-$MM-$DD-release

