#!/usr/bin/env zsh

FROM="+12125551234"
TO="+13105555555"
BODY="Hello,%20Twirled!"

DATA="from=$FROM&to=$TO&body=$BODY"
HOST="http://localhost:4000/webhook/twilio"

curl -X POST -d "$DATA" $HOST
