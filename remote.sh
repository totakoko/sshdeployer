#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

usage() {
  echo 'Usage: remote "shell commands..."'
  exit 1
}

update_ssh_configuration() {
  if [ -n "$SSH_FINGERPRINT_BASE64" ]; then
    export SSH_FINGERPRINT=$(echo $SSH_FINGERPRINT_BASE64 | base64 -d)
  fi
  if [ -z "$SSH_FINGERPRINT" ]; then
    echo "Missing environment variable SSH_FINGERPRINT"
    exit 1
  fi
  if [ -n "$SSH_PRIVATE_KEY_BASE64" ]; then
    export SSH_PRIVATE_KEY=$(echo $SSH_PRIVATE_KEY_BASE64 | base64 -d)
  fi
  if [ -z "$SSH_PRIVATE_KEY" ]; then
    echo "Missing environment variable SSH_PRIVATE_KEY"
    exit 1
  fi

  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  eval $(ssh-agent -s) > /dev/null
  if ! echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -; then
    echo "Could not load SSH_PRIVATE_KEY. Wrong format?"
    exit 1
  fi
  echo "$SSH_FINGERPRINT" >> ~/.ssh/known_hosts
}

# handle legacy SERVER_* variables
SSH_HOST=${SSH_HOST:-$SERVER_HOST}
SSH_FINGERPRINT=${SSH_FINGERPRINT:-$SERVER_FINGERPRINT}
SSH_PORT=${SSH_PORT:-$SERVER_PORT}

# default values
SSH_USER=${SSH_USER:-root}
SSH_PORT=${SSH_PORT:-22}

# in case the host contains the user
if [[ "$SSH_HOST" =~ .*"@".* ]]; then
  echo "Warning: SSH_HOST contains the user. You should use SSH_USER instead."
  SSH_USER=${SSH_HOST%@*}
  SSH_HOST=${SSH_HOST#*@}
fi

if [[ -z "$SSH_HOST" ]]; then
  echo "Missing environment variable SSH_HOST"
  exit 1
fi
if [[ -z "$SSH_FINGERPRINT" ]]; then
  echo "Missing environment variable SSH_FINGERPRINT"
  exit 1
fi
if [[ -z "$SSH_PRIVATE_KEY" ]]; then
  echo "Missing environment variable SSH_PRIVATE_KEY"
  exit 1
fi
if [[ $# -eq 0 ]]; then
  echo "Missing remote commands"
  exit 1
fi

if [ -n "$SSH_FROM_ENV" ]; then
  update_ssh_configuration
fi

sshClient="ssh -T -o BatchMode=true -p $SSH_PORT $SSH_USER@$SSH_HOST"

echo "> Testing connectivity..."
if $sshClient true; then
  echo "> Testing connectivity: SUCCESS"
else
  code=$?
  echo "> Testing connectivity: FAILED"
  echo
  echo "/!\\"
  echo "Connectivity test failed with status: $code"
  echo "Please review your configuration"
  echo "/!\\"
  exit $code
fi

echo "> Running commands..."
if $sshClient "set -e; $@"; then
  echo "> Running commands: SUCCESS"
else
  code=$?
  echo "> Running commands: FAILED"
  echo
  echo "/!\\"
  echo "Remote commands failed with status: $code"
  echo "/!\\"
  exit $code
fi
