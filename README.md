# FieldTrip automation

This repository contains various scripts used to manage releases and to link the
different development tools together. Some scripts are executed by cron jobs and
some scripts are executed by webhooks. The webhooks are triggered following a
pull request or merged commit on GitHub to the [fieldtrip/fieldtrip](https://github.com/fieldtrip/fieldtrip)
or [fieldtrip/website](https://github.com/fieldtrip/website) repositories.

The documentation on <http://www.fieldtriptoolbox.org/development/integration>
has some additional details.


## fieldtrip/fieldtrip

This uses a webhook processed by the [DCCN webhook](https://github.com/Donders-Institute/hpc-webhook) service. It does the following

- send a tweet
- github maintenance
  - synchronize identical files in the different private directories and push the update back to GitHub
  - synchronize the GitHub repository to BitBucket and Gitlab
  - synchronize the fileio repository on GitHub
  - synchronize the qsub repository on GitHub
- recreate the reference documentation


## fieldtrip/website

This uses a webhook processed by the [DCCN webhook](https://github.com/Donders-Institute/hpc-webhook) service. It does the following

- rebuild the website
  - update the tags and push the update back to GitHub
  - rebuild the static version of the website
  - add some assets that are not part of the repository


## cronjob

Furthermore there are a number of daily jobs running in a cronjob on the DCCN compute cluster. These take care of the following

- execute all test scripts using the dashboard batch
   - at the end this will check whether all tests passed, merge changes to the release branch and make a tag
- send an email with the latest dashboard results
- make the latest release available on the ftp server
- make the latest release available at the DCCN under home/common

