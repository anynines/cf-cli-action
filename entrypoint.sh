#!/bin/sh -l

INPUT_CF_API=$(echo "$1" | jq -r '.cf_api')
INPUT_CF_USERNAME=$(echo "$1" | jq -r '.cf_username')
INPUT_CF_PASSWORD=$(echo "$1" | jq -r '.cf_password')
INPUT_CF_ORG=$(echo "$1" | jq -r '.cf_org')
INPUT_CF_SPACE=$(echo "$1" | jq -r '.cf_space')
INPUT_RETRIES=$(echo "$1" | jq -r '.retries | try tonumber catch 3')
INPUT_COMMAND=$(echo "$1" | jq -r '.command')
INPUT_SKIP_SSL_VALIDATION=$(echo "$1" | jq -r '.skip_ssl_validation')

CF_CLI_OPTIONS=""
if [ "$INPUT_SKIP_SSL_VALIDATION" = "true" ]; then
  CF_CLI_OPTIONS="$CF_CLI_OPTIONS --skip-ssl-validation"
fi

cf8 api "$INPUT_CF_API" $CF_CLI_OPTIONS
cf8 auth "$INPUT_CF_USERNAME" "$INPUT_CF_PASSWORD"

if [ -n "$INPUT_CF_ORG" ] && [ -n "$INPUT_CF_SPACE" ]; then
  cf8 target -o "$INPUT_CF_ORG" -s "$INPUT_CF_SPACE"
fi

attempt=1
while [ $attempt -le "$INPUT_RETRIES" ]; do
  sh -c "cf8 $INPUT_COMMAND"

  if [ $? -eq 0 ]; then
    echo "Deployment Succesful."
    exit 0
  fi
  
  echo "Failed, attempt $attempt of $INPUT_RETRIES."
  attempt=$((attempt + 1))
done

echo "Maximum of $INPUT_RETRIES retry attempts reached. Exiting..."
exit 1
