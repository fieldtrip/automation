#!/usr/bin/env node

// this requires that you source the environment variables from apikey.sh

var http = require('http')
var child_process = require('child_process');

var createHandler = require('github-webhook-handler')
var handler = createHandler({ path: '/github', secret: process.env.GITHUB_SECRET })

var Twitter = require('twitter');
var twitter = new Twitter({
  consumer_key:         process.env.TWITTER_CONSUMER_KEY,
  consumer_secret:      process.env.TWITTER_CONSUMER_SECRET,
  access_token_key:     process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret:  process.env.TWITTER_ACCESS_TOKEN_SECRET,
});

var Bitly = require('bitly');
var bitly = new Bitly(process.env.BITLY_API_KEY);

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    // res.statusCode = 404
    // res.end('no such location')
    res.writeHead(302, {'Location': 'http://www.fieldtriptoolbox.org/'});
    res.end();
  })
}).listen(process.env.PORT)

handler.on('error', function (err) {
  console.error('Error:', err.message)
})

handler.on('issues', function (event) {
  console.log('Received an issue event for %s action=%s: #%d %s',
    event.payload.repository.name,
    event.payload.action,
    event.payload.issue.number,
    event.payload.issue.title)
})

handler.on('push', function (event) {
  console.log('Received a push event for %s to %s', event.payload.repository.name, event.payload.ref);
  child_process.execFile(__dirname + '/github.sh'); // [, args][, options][, callback])
  event.payload.commits.forEach(function (commit, index) {
    bitly.shorten(commit.url)
      .then(function(response) {
        var short_url = response.data.url;
        var author = commit.author.name;
        // clean up a bit, remove git-svn-id and remove lines beyond the 1st one
        var message = author + "(github): " + commit.message.replace(/git-svn-id.*/, "");
        message = message.split("\n")[0];
        message = message.substring(0, 139 - short_url.length) + " " + short_url;
        console.log('------------------------------------------')
        console.log(message);
        console.log('------------------------------------------')
        twitter.post('statuses/update', {status: message},  function(error, tweet, response){
          if(error) {
            throw error; // error in calling twitter
          }
          // console.log(tweet);     // Tweet body.
          // console.log(response);  // Raw response object.
        });

      }, function(error) {
        throw error; // error in calling bitly
      });

  });
});
