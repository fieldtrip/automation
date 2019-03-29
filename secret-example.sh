export PORT_FIELDTRIP=xxxx
export PORT_WEBSITE=xxxx

export GITHUB_SECRET='xxxxxxxxxx'

export BITLY_API_KEY='xxxxxxxxxx'

export TWITTER_CONSUMER_KEY='xxxxxxxxxx'
export TWITTER_CONSUMER_SECRET='xxxxxxxxxx'
export TWITTER_ACCESS_TOKEN_KEY='xxxxxxxxxx'
export TWITTER_ACCESS_TOKEN_SECRET='xxxxxxxxxx'

if [ -f secret.sh ] ; then
source secret.sh
fi

