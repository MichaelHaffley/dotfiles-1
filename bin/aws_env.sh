#!/usr/bin/env bash
# ./aws_env.sh code filename
# filename defaults to aws_env.sh.source

readonly arn="arn:aws:iam::973692506099:mfa/$USER"
if [ "$#" -eq 2 ]; then
  readonly code=${2}
  readonly output="${1}"
else
  readonly code=${1}
  readonly output="$HOME/.aws/env"
fi

rm -f $output
unset AWS_ACCESS_KEY_ID
unset AWS_SESSSION_TOKEN
unset AWS_SECRET_ACCESS_KEY
readonly json="$(aws sts get-session-token --serial-number $arn --token-code $code)"
readonly access_key_id=$(echo $json | jq -r '.[].AccessKeyId')
echo "export AWS_ACCESS_KEY_ID=$access_key_id" >> $output
readonly session_token=$(echo $json | jq -r '.[].SessionToken')
echo "export AWS_SESSION_TOKEN=$session_token" >> $output
readonly secret_access_key=$(echo $json | jq -r '.[].SecretAccessKey')
echo "export AWS_SECRET_ACCESS_KEY=$secret_access_key" >> $output

echo "Now type on the command line: source $output"

