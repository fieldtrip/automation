#!/usr/bin/env node

// this requires that you source the environment variables from secret.sh

var http = require('http')
var child_process = require('child_process');

var createHandler = require('github-webhook-handler')
var handler = createHandler({ path: '/github', secret: process.env.GITHUB_SECRET_FIELDTRIP })

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    // res.statusCode = 404
    // res.end('no such location')
    res.writeHead(302, {'Location': 'http://www.fieldtriptoolbox.org/'});
    res.end();
  })
}).listen(process.env.PORT_FIELDTRIP)

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
});
