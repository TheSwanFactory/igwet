#!/usr/bin/env zsh
# Usage: sh test/support/send_sms.sh

# Create nodes:  PHONE_IGWET (PHONE_ERNEST PHONE_TGR)

source .env
BODY="What%20Hath%20God%20Wrought!"
MSG_SID='20200906162900'
TEST_HOST=https://localhost:$PORT
PROD_HOST=https://www.igwet.com

DATA="From=$PHONE_ERNEST&To=$PHONE_IGWET&Body=$BODY&MessageSid=$MSG_SID&AccountSid=$TWILIO_ACCOUNT_SID"
TWILIO_DATA="AccountSid=ACf5fa19f6ee930569ea148ab4b1807f6f&ApiVersion=2010-04-01&Body=What%20rot%20hath%20God&From=%2B14086233809&FromCity=SAN JOSE&FromCountry=US&FromState=CA&FromZip=95076&MessageSid=SM2c0aa2296fa158bc36f5ab0018058154&MessagingServiceSid=MGb357c80caa9d892513a88b8273b1748a&NumMedia=0&NumSegments=1&SmsMessageSid=SM2c0aa2296fa158bc36f5ab0018058154&SmsSid=SM2c0aa2296fa158bc36f5ab0018058154&SmsStatus=received&To=%2B12108800550&ToCity=SAN ANTONIO&ToCountry=US&ToState=TX&ToZip=78215"

URL="$TEST_HOST/webhook/log_sms"
echo "$URL: $TWILIO_DATA"
curl -k -X POST -d "$TWILIO_DATA" $URL
