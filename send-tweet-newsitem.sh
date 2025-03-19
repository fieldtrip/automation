#!/bin/bash
#
# Send a social media update for new news items posts
#
# This makes use of 
#   - https://github.com/sferik/t
#   - https://github.com/mattn/bsky

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
SORT=/usr/bin/sort
TAIL=/usr/bin/tail
ZIP=/usr/bin/zip
RSYNC=/usr/bin/rsync

TWEET=$HOME/.rvm/gems/ruby-2.5.3/bin/t
TOOT=$HOME/.nvm/versions/node/v16.18.1/bin/toot
BSKY=$HOME/.gvm/pkgsets/go1.23.3/global/bin/bsky

# specify working directories
PROJECTDIR=/project/3031000.02
WEBSITEDIR=$PROJECTDIR/website
HASHFILE=$PROJECTDIR/tweet.log

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
  echo $HASH >> $HASHFILE
  echo posting $HASH: "$MESSAGE"
  ### $TWEET update "$MESSAGE"
  $TOOT "$MESSAGE"
  $BSKY post "$MESSAGE"
else
  echo not posting $HASH: "$MESSAGE"
fi

fi   # the message is not empty
done # for each post

