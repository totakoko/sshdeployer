#!/bin/sh -e

if [[ -z "$SERVER_HOST" ]]; then
  echo "Missing environment variable SERVER_HOST"
  exit 1
fi
if [[ -z "$SSH_PRIVATE_KEY" ]]; then
  echo "Missing environment variable SSH_PRIVATE_KEY"
  exit 1
fi
if [[ -z "$SERVER_FINGERPRINT" ]]; then
  echo "Missing environment variable SERVER_FINGERPRINT"
  exit 1
fi
if [[ $# -eq 0 ]]; then
  echo "Missing remote commands"
  exit 1
fi

SERVER_PORT=${SERVER_PORT:-22}

echo "Deploying to ${SERVER_HOST}:${SERVER_PORT}..."
eval $(ssh-agent -s) > /dev/null
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
echo "$SERVER_FINGERPRINT" >> ~/.ssh/known_hosts
ssh -T -p $SERVER_PORT $SERVER_HOST "$@"
