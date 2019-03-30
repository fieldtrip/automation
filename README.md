# FieldTrip webhook

This repository contains various scripts used to manage releases and to link the
different development tools together. Some scripts are executed by cron jobs and
some scripts are executed by webhooks. The webhooks are triggered following a
pull request or merged commit on GitHub to the [fieldtrip/fieldtrip](https://github.com/fieldtrip/fieldtrip)
or [fieldtrip/website](https://github.com/fieldtrip/website) repositories.

The documentation on <http://www.fieldtriptoolbox.org/development/integration>
has some additional details.

This repository also contains a simple webhook server that is implemented using
[Node.js](https://nodejs.org/en/). It can be used to execute Bash scripts and it
also includes some code to send a tweet. To start the webhook server, you should
execute the following code:

```
source ./secret.sh
nvm use v4.2.6
forever start webhook.js
```

## fieldtrip/fieldtrip

One webhook is processed by the webhook server running on a dedicated Raspberry
Pi. It does the following

- synchronize identical files in the different private directories and push the update back to GitHub
- synchronize the GitHub repository to BitBucket and Gitlab
- synchronize the fileio repository on GitHub
- synchronize the qsub repository on GitHub
- send a tweet

Another webhook is processed using the DCCN webhook service. It does the following

- recreate the reference documentation
- update the copy of the FieldTrip on DCCN central storage

## fieldtrip/website

This uses a webhook processed by the DCCN webhook service. It does the following

- update the tags and push the update back to GitHub
- rebuild the static version of the website
- add some assets to the website that are not part of the repository
