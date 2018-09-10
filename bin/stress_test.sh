#!/bin/bash
echo -n Password:
read -s PASSWORD
echo
while :
do
  curl --user "$USER:$PASSWORD" --request GET https://atl1q39tacow02.qa.local/v1/environments -k || break
  curl --user "$USER:$PASSWORD" --request GET https://atl1q39tacow02.qa.local/v1/products -k || break
  curl --user "$USER:$PASSWORD" --request GET https://atl1q39tacow02.qa.local/v1/features -k || break
  curl --user "$USER:$PASSWORD" --request GET https://atl1q39tacow02.qa.local/v1/users -k || break
  curl --user "$USER:$PASSWORD" --request GET https://atl1q39tacow02.qa.local/v1/execution_collections -k || break
  curl --user "$USER:$PASSWORD" --request GET https://atl1q39tacow02.qa.local/v1/execution_records -k || break
done
