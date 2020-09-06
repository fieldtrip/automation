#!/bin/bash
#
# This script makes a changelog entry from the git commits, comparing
# the latest tag/release to the one before.
#

TARGETDIR=$HOME/fieldtrip/release/website
TRUNK=$HOME/fieldtrip/release/fieldtrip

##############################################################################

cd $TRUNK || exit 1

CURRENT=`git tag | grep 20..... | sort | tail -1 | head -1`
PREVIOUS=`git tag | grep 20..... | sort | tail -2 | head -1`

YYYY=${CURRENT:0:4}
MM=${CURRENT:4:2}
DD=${CURRENT:6:2}

if [ $MM==01 ] ; then
MONTH=January
elif [ $MM==02 ] ; then
MONTH=February
elif [ $MM==03 ] ; then
MONTH=March
elif [ $MM==04 ] ; then
MONTH=April
elif [ $MM==05 ] ; then
MONTH=May
elif [ $MM==06 ] ; then
MONTH=June
elif [ $MM==07 ] ; then
MONTH=July
elif [ $MM==08 ] ; then
MONTH=August
elif [ $MM==09 ] ; then
MONTH=September
elif [ $MM==10 ] ; then
MONTH=October
elif [ $MM==11 ] ; then
MONTH=November
elif [ $MM==12 ] ; then
MONTH=December
fi

RELEASEURL="[$CURRENT](http://github.com/fieldtrip/fieldtrip/releases/tag/$CURRENT)"
TEMPFILE=`mktemp`

cat > $TEMPFILE << EOF
---
title: $DD $MONTH $YYYY - FieldTrip version $CURRENT has been released
categories: [news, release]
---

### $DD $MONTH, $YYYY

FieldTrip version $RELEASEURL has been released.

#### Commits

EOF

# use awk to convert it into a list and to add the URL to each commit
git log --oneline $PREVIOUS...$CURRENT | awk '$1="- ["$1"](http://github.com/fieldtrip/fieldtrip/commit/"$1")"' >> $TEMPFILE

##############################################################################

# the following uses https://github.com/github/hub
# which is installed using anaconda
module load anaconda3
source activate hub

cd $TARGETDIR || exit 1

if [ -e "$TARGETDIR/_posts/$YYYY-$MM-$DD-release.md" ] ; then
# there is already a news item for this release
exit 0
fi

git checkout master
git pull origin master
git checkout -b $YYYY-$MM-$DD-release
cp $TEMPFILE "$TARGETDIR/_posts/$YYYY-$MM-$DD-release.md"
git add "$TARGETDIR/_posts/$YYYY-$MM-$DD-release.md"
git commit -am "added news item for release"
git push --set-upstream origin $YYYY-$MM-$DD-release
# hub pull-request -m "add news item for release $CURRENT"
git checkout master
git branch -D $YYYY-$MM-$DD-release

