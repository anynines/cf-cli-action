#!/bin/sh -l


: ${INPUT_RETRIES:=3}

INPUT_CF_API=$(echo "$1" | jq '.cf_api')
INPUT_CF_USERNAME=$(echo "$1" | jq '.cf_username')
INPUT_CF_PASSWORD=$(echo "$1" | jq '.cf_password')
INPUT_CF_ORG=$(echo "$1" | jq '.cf_org')
INPUT_CF_SPACE=$(echo "$1" | jq '.cf_space')
INPUT_RETRIES=$(echo "$1" | jq '.retries')
INPUT_COMMAND=$(echo "$1" | jq '.command')

attempt=1

while [ $attempt -le "$INPUT_RETRIES" ]; do

  cf8 api "$INPUT_CF_API"
  cf8 auth "$INPUT_CF_USERNAME" "$INPUT_CF_PASSWORD"

  if [ -n "$INPUT_CF_ORG" ] && [ -n "$INPUT_CF_SPACE" ]; then
    cf8 target -o "$INPUT_CF_ORG" -s "$INPUT_CF_SPACE"
  fi

  sh -c "cf8 $INPUT_COMMAND"

  if [ $? -eq 0 ]; then
    echo "Deployment Succesful."
    break
  else
    echo "Failed, Attempt $attempt of $INPUT_RETRIES."
    attempt=$((attempt + 1))

    if [ $attempt -gt "$INPUT_RETRIES" ]; then
      echo "Maximum retry attempts reached. Exiting."
      exit 1
    fi
  fi
done