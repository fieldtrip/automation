FieldTrip webhook
=================

These are various webhook scripts used for the FieldTrip project to
manage releases and to link the different development tools together.

See http://www.fieldtriptoolbox.org/development/integration for details.

To start the webhook server, you should do

```
source ./secret.sh
nvm use v4.2.6
forever start webhook.js
```
