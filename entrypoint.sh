#!/bin/sh -l

: ${INPUT_RETRIES:=3}

attempt=1
env

while [ $attempt -le $INPUT_RETRIES ]; do

  cf8 api "$INPUT_CF_API"
  cf8 auth "$INPUT_CF_USERNAME" "$INPUT_CF_PASSWORD"

  if [ -n "$INPUT_CF_ORG" ] && [ -n "$INPUT_CF_SPACE" ]; then
    cf8 target -o "$INPUT_CF_ORG" -s "$INPUT_CF_SPACE"
  fi

  sh -c "cf8 $*"

  if [ $? -eq 0 ]; then
    echo "Deployment Succesful."
    break
  else
    echo "Failed, Attempt $attempt of $INPUT_RETRIES."
    attempt=$((attempt + 1))

    if [ $attempt -gt $INPUT_RETRIES ]; then
      echo "Maximum retry attempts reached. Exiting."
      exit 1
    fi
  fi
done