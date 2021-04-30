#!/bin/bash

set -x

USERS=($(echo $USERNAMES | tr "," "\n"))

aws configure set aws_access_key_id $ACCESS_KEY
aws configure set aws_secret_access_key $SECRET_KEY
aws configure set region $REGION

for USER in "${USERS[@]}"
do

  WAITING_FOR_USER=true

  while $WAITING_FOR_USER; do
    aws identitystore list-users --identity-store-id $IDENTITY_STORE_ID \
      --filters AttributePath=UserName,AttributeValue=$USER > user.txt
    if grep -q $USER ./user.txt; then
      echo "User: $USER Found";
      WAITING_FOR_USER=false;
    else
      echo "User: $USER not Found, sleeping 300s";
      sleep 300;
    fi
    rm -rf user.txt
  done

done
