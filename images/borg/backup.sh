#!/bin/sh
set -e

VOLUMES_DIR="${VOLUMES_DIR:-/volumes}"

volumes(){
    find "$VOLUMES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

_create(){
    for volume in $(volumes); do
        borg create --stats --compression lz4 "::${volume}--{now}" "${VOLUMES_DIR}/${volume}"
    done
}

_prune(){
    for volume in $(volumes); do
        borg prune -v --keep-daily=7 --keep-weekly=4 --keep-monthly=6 --keep-yearly=2 --list --glob-archives="${volume}"'--*'
    done
    borg compact
}

COMMAND="${1:-create}"

case "${COMMAND}" in
    create) _create ;;
    prune) _prune ;;
    *) echo "Usage: $0 [create]" >&2 ;;
esac


