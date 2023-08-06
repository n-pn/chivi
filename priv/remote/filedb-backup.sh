#!/usr/bin/env bash

echo "Backup from chivi.app!"

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --compress-level=3 --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

REMOTE=nipin@ssh.chivi.app
SSH=$REMOTE:/app/chivi

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup users data!
  rsync-fast "$SSH/var/_conf" "var"
  rsync-fast --delete "$SSH/var/ulogs/daily/" "var/ulogs/daily/"
fi

## backup dict data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!
  rsync-fast "$SSH/var/mtapp/v1dic/" "var/mtapp/v1dic/"
fi

## backup book data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  # rsync-fast "$SSH/var/wninfos/autos" "var/wninfos"

  rsync-fast "$SSH/var/files/covers" "var/files"
  rsync-fast "$SSH/var/chaps/" "var/chaps/"
  rsync-fast "$SSH/var/texts/" "var/texts/"

  rsync-fast "$SSH/var/.keep/rmbook" "var/.keep/rmbook"
  rsync-fast "$SSH/var/.keep/rmchap" "var/.keep/rmchap"
fi

## backup book data
if [[ $* == *misc* ]]
then
  echo backup miscs data!
  # rsync-fast "$SSH/var/texts/edits" "var/texts"
  # rsync-fast "$SSH/var/texts/trans" "var/texts"

  rsync-fast "$SSH/var/zroot/bcovers.db" "var/zroot"

fi

## backup pg_data
if [[ $1 == "all" || $* == *pgdb* ]]
then
  echo backup pg_data!
  rsync-fast --delete "nipin@ssh.chivi.app:_db/wals" _db
  rsync-fast --delete "nipin@ssh.chivi.app:_db/data" _db
fi
