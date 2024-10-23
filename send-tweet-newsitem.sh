#!/bin/bash
#
# Send an update to twitter for all (new) posts with news items.
#
# This makes use of 
#   - https://github.com/sferik/t

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

T=$HOME/.rvm/gems/ruby-2.5.3/bin/t

TOOTCONFIG=/home/megmethods/roboos/.mastodon.json
TOOT=$HOME/.nvm/versions/node/v16.18.1/bin/toot
NODE=$HOME/.nvm/versions/node/v16.18.1/bin/node

# specify working directories
PROJECTDIR=/home/megmethods/roboos
WEBSITEDIR=$PROJECTDIR/fieldtrip/website
HASHFILE=$PROJECTDIR/fieldtrip/tweet.log

touch $HASHFILE

##############################################################################

cd $WEBSITEDIR || exit 1

$GIT checkout master > /dev/null 2>&1
$GIT pull origin master > /dev/null 2>&1

for post in _posts/*.md ; do 
MESSAGE=`$AWK '/^tweet:/ {for (i=2; i<=NF; i++) printf $i " " }' $post`

if [ ! -z "$MESSAGE" ] ; then
HASH=`echo "$MESSAGE" | md5sum | cut -f 1 -d " "`

if ! $( grep -q $HASH $HASHFILE ) ; then
  echo sending tweet and toot: "$MESSAGE"
  $T update "$MESSAGE"
  echo "$MESSAGE" | $NODE $TOOT --config "$TOOTCONFIG"
  echo $HASH >> $HASHFILE
else
  echo not sending tweet or toot: "$MESSAGE"
fi

fi   # the message is not empty
done # for each post

