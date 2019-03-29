# FieldTrip webhook

These are various scripts used to manage releases and to link the different development
tools together. These scripts are executed by webhooks, which are triggered following a
pull-request or merged commit on GitHub to the [fieldtrip/fieldtrip](https://github.com/fieldtrip/fieldtrip)
or [fieldtrip/website](https://github.com/fieldtrip/website) repositories.

The documentation on <http://www.fieldtriptoolbox.org/development/integration> has some additional details.

To start the webhook server, you should execute the following code:

```
source ./secret.sh
nvm use v4.2.6
forever start webhook.js
```

## fieldtrip/fieldtrip

One webhook is implemented using a dedicated Raspberry Pi. It does the following

- synchronize identical files in the different private directories and push update back to GitHub
- synchronize the GitHub repository to BitBucket and Gitlab
- synchronize the fileio repository on GitHub
- synchronize the qsub repository on GitHub
- send a tweet

Another webhook is implemented using the DCCN webhook service. It does the following

- recreate the reference documentation
- update the copy of the FieldTrip code on DCCN central storage

## fieldtrip/website

This uses a webhook that is implemented with the DCCN webhook service. It does the following

- update the tags and push update back to GitHub
- rebuild the static version of the website
- add some assets to the website that are not in the repository
