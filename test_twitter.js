#!/usr/bin/env node

// this requires that you source the environment variables from apikey.sh

var Twitter = require('twitter');
var twitter = new Twitter({
  consumer_key:         process.env.TWITTER_CONSUMER_KEY,
  consumer_secret:      process.env.TWITTER_CONSUMER_SECRET,
  access_token_key:     process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret:  process.env.TWITTER_ACCESS_TOKEN_SECRET,
});

var params = {screen_name: 'fieldtriptoolbx'};
client.get('statuses/user_timeline', params, function(error, tweets, response){
  if (!error) {
    console.log(tweets);
  }
});

client.post('statuses/update', {status: 'test for http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=3049'},  function(error, tweet, response){
  if(error) throw error;
  console.log(tweet);  // Tweet body. 
  console.log(response);  // Raw response object. 
});
