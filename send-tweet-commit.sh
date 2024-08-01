#!/bin/bash
#
# Send an update to twitter whenever something gets pushed to or merged with the fieldtrip repository
#
# This makes use of 
#   - https://github.com/sferik/t
#   - https://stedolan.github.io/jq/
#   - https://github.com/jgorset/git.io

echo Executing $0

URL=`jq .head_commit.url $HOME/.webhook/fieldtrip/payload`
URL=${URL:1:-1}
SHORTURL=`git.io $URL`

MESSAGE=`jq .head_commit.message $HOME/.webhook/fieldtrip/payload`
MESSAGE=${MESSAGE:0:120}
MESSAGE="$MESSAGE ... See $SHORTURL"

t update "$MESSAGE"
