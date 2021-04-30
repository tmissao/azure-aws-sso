#!/bin/bash

USERS=($(echo $USER_IDS | tr "," "\n"))

az login --service-principal --username $CLIENT_ID --password $CLIENT_SECRET --tenant $TENANT_ID --allow-no-subscriptions

for user in "${USERS[@]}"
do
  az rest --method get --uri "https://graph.microsoft.com/v1.0/users/$user/appRoleAssignments?$filter=resourceId eq $SP_OBJECT_ID" \
    > result.txt
  if grep -q "$SP_OBJECT_ID" ./result.txt; then
    echo "User $user already has SSO configured"
  else
    az rest --method post --uri "https://graph.microsoft.com/v1.0/users/$user/appRoleAssignments" \
     --body "{\"appRoleId\": \"$APP_ROLE_ID\",\"principalId\": \"$user\",\"resourceId\": \"$SP_OBJECT_ID\"}" \
     --headers "Content-Type=application/json"
  fi
  rm -rf result.txt
done
