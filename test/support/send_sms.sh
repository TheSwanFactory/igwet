#!/usr/bin/env zsh
# Usage: sh test/support/send_sms.sh

# Create nodes:  PHONE_IGWET (PHONE_ERNEST PHONE_TGR)

source .env
BODY="Hello,%20Twirled!"
MSG_SID='123456789'

DATA="from=$PHONE_TGR&to=$PHONE_IGWET&body=$BODY&MessageSid=$MSG_SID&AccountSid=$TWILIO_ACCOUNT_SID"
HOST="https://localhost:$PORT/webhook/twilio"
echo "$HOST: $DATA"
curl -k -X POST -d "$DATA" $HOST
