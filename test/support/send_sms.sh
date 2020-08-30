#!/usr/bin/env zsh

FROM="+12125551234"
TO="+13105555555"
BODY="Hello,%20Twirled!"
SID='123456789'

DATA="from=$FROM&to=$TO&body=$BODY&MessageSid=$SID"
HOST="https://localhost:4000/webhook/twilio"

curl -k -X POST -d "$DATA" $HOST
