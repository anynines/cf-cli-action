#!/bin/sh -l

: ${INPUT_RETRIES:=3}

INPUT_CF_API=$(jq -r '.cf_api' <<< "$1")
INPUT_CF_USERNAME=$(jq -r '.cf_username' <<< "$1")
INPUT_CF_PASSWORD=$(jq -r '.cf_password' <<< "$1")
INPUT_CF_ORG=$(jq -r '.cf_org' <<< "$1")
INPUT_CF_SPACE=$(jq -r '.cf_space' <<< "$1")
INPUT_RETRIES=$(jq -r '.retries | tonumber' <<< "$1")
INPUT_COMMAND=$(jq -r '.command' <<< "$1")
INPUT_SKIP_SSL_VALIDATION=$(jq -r '.skip_ssl_validation' <<< "$1")

cf api "$INPUT_CF_API"
cf8 auth "$INPUT_CF_USERNAME" "$INPUT_CF_PASSWORD"

if [ -n "$INPUT_CF_ORG" ] && [ -n "$INPUT_CF_SPACE" ]; then
  cf8 target -o "$INPUT_CF_ORG" -s "$INPUT_CF_SPACE"
fi

attempt=1
while [ $attempt -le "$INPUT_RETRIES" ]; do
  if [ $INPUT_SKIP_SSL_VALIDATION -eq "true"]; then
    sh -c "cf8 $INPUT_COMMAND --skip-ssl-validation"
  else
     sh -c "cf8 $INPUT_COMMAND"
  fi


  if [ $? -eq 0 ]; then
    echo "Deployment Succesful."
    exit 0
  fi

  attempt=$((attempt + 1))
  echo "Failed, attempt $attempt of $INPUT_RETRIES."
fi

echo "Maximum of $INPUT_RETRIES retry attempts reached. Exiting..."
exit 1