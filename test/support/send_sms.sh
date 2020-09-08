#!/usr/bin/env zsh
# Usage: sh test/support/send_sms.sh

# Create nodes:  PHONE_IGWET (PHONE_ERNEST PHONE_TGR)

source .env
BODY="What%20Hath%20God%20Wrought!"
MSG_SID='20200906162900'
TEST_HOST=https://localhost:$PORT
PROD_HOST=https://www.igwet.com

DATA="from=$PHONE_ERNEST&to=$PHONE_IGWET&body=$BODY&MessageSid=$MSG_SID&AccountSid=$TWILIO_ACCOUNT_SID"
URL="$TEST_HOST/webhook/log_sms"
echo "$URL: $DATA"
curl -k -X POST -d "$DATA" $URL
