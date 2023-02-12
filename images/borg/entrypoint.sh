#!/bin/sh
set -e

ERROR=0

# Path to Borg repository
if [ -f /run/secrets/BORG_REPO ]; then
    BORG_REPO=$(cat /run/secrets/BORG_REPO)
fi
if [ -z "$BORG_REPO" ]; then
    echo "ERROR: BORG_REPO is not set" >&2 ; ERROR=1
fi

# Passphrase for borg repo
if [ -f /run/secrets/BORG_PASSPHRASE ]; then
    BORG_PASSPHRASE=$(cat /run/secrets/BORG_PASSPHRASE)
fi
if [ -z "$BORG_PASSPHRASE" ]; then
    echo "ERROR: BORG_PASSPHRASE is not set" >&2 ; ERROR=1
fi

# SSH private key for accessing borg remote
if [ -f /run/secrets/BORG_SSH_PRIVATE_KEY ]; then
    BORG_SSH_PRIVATE_KEY=$(cat /run/secrets/BORG_SSH_PRIVATE_KEY)
fi
if [ -z "$BORG_SSH_PRIVATE_KEY" ]; then
    echo "ERROR: BORG_SSH_PRIVATE_KEY is not set" >&2 ; ERROR=1
fi

set -u

if [ $ERROR -ne 0 ]; then exit 1; fi

# Dump passphrase and keyfile data to file and set borg env vars
echo "$BORG_PASSPHRASE" > ~/.borg_passphrase
chmod 400 ~/.borg_passphrase
BORG_PASSCOMMAND="cat $HOME/.borg_passphrase"
unset BORG_PASSPHRASE

# Create SSH private key
if [ ! -d ~/.ssh/ ]; then mkdir -m 0600 ~/.ssh; fi
echo "$BORG_SSH_PRIVATE_KEY" | base64 -d > ~/.ssh/borg-privatekey
chmod 400 ~/.ssh/borg-privatekey
unset BORG_SSH_PRIVATE_KEY
BORG_RSH="ssh -i $HOME/.ssh/borg-privatekey"

# Extract borg host/port from BORG_REPO
TEMP_FILE="$(mktemp)"
trap 'rm -f $TEMP_FILE' EXIT INT QUIT TERM
echo "$BORG_REPO" | sed -E 's,ssh://([^@]+)@([^:]+):(\d+)/(.*),\2\n\3,' > "$TEMP_FILE"
while true; do
    read -r BORG_SSH_HOST
    read -r BORG_SSH_PORT
    break
done < "$TEMP_FILE"
rm "$TEMP_FILE"

# Add server public keys to known_hosts
if [ ! -f "$HOME/.ssh/known_hosts" ]; then
    echo "Updating known_hosts ..."
    { ssh-keyscan -H -p "$BORG_SSH_PORT" "$BORG_SSH_HOST" >"$HOME/.ssh/known_hosts"; } 2>&1 | sed -n '/^[^#]/p'
fi

# Export required env vars
export BORG_REPO
export BORG_PASSCOMMAND
export BORG_RSH

if ! borg info >/dev/null; then
    echo "Initialising borg repository: $BORG_REPO"
    borg init -e repokey
    #borg create --stats --compression lz4 '::{now}' /data
fi

/bin/sh -c '$@' -- "$@"
