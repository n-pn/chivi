#!/usr/bin/env bash

echo "Backup from chivi.app!"

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --compress-level=3 --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

REMOTE=nipin@chivi.app
SSH=$REMOTE:/app/chivi

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup users data!
  rsync-fast --delete "$REMOTE:/srv/chivi/ulogs/daily" srv/chivi/ulogs
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

  rsync-fast "$SSH//srv/chivi/.keep/rmbook" "/srv/chivi/.keep/rmbook"
  rsync-fast "$SSH//srv/chivi/.keep/rmchap" "/srv/chivi/.keep/rmchap"
fi

## backup book data
if [[ $* == *misc* ]]
then
  echo backup miscs data!
  # rsync-fast "$SSH/var/texts/edits" "var/texts"
  # rsync-fast "$SSH/var/texts/trans" "var/texts"

  rsync-fast "$SSH/var/zroot/bcovers.db" "/srv/chivi/zroot"

fi

## backup pg_data
if [[ $1 == "all" || $* == *pgdb* ]]
then
  echo backup pg_data!
  rsync-fast --delete "nipin@ssh.chivi.app:_db/wals" _db
  rsync-fast --delete "nipin@ssh.chivi.app:_db/data" _db
fi
