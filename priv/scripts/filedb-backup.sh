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
  rsync-fast "$SSH/var/fixed" "var"
  rsync-fast --delete "$SSH/var/.keep/web_log/" "var/.keep/web_log/"
  rsync-fast --delete "$SSH/var/cvmtl/users/" "var/cvmtl/users/"
fi

## backup dict data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!

  # rsync-fast "$SSH/var/dicts/v1/" "var/dicts/v1/"
  # rsync-fast "$SSH/var/dicts/ulogs" "var/dicts"

  rsync-fast "$SSH/var/dicts/v1log" "var/dicts"
  rsync-fast "$SSH/var/dicts/v1raw" "var/dicts"
  rsync-fast "$SSH/var/users" "var"
  # rsync-fast "$SSH/var/dicts/v1dic" "var/dicts"
fi

## backup book data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  # rsync-fast "$SSH/var/nvinfos/autos" "var/nvinfos"

  rsync-fast "$SSH/var/books/infos" "var/books"
  rsync-fast "$SSH/var/books/cover" "var/books"
  # rsync-fast "$SSH/var/books/seeds" "var/books"

  rsync-fast "$SSH/var/chaps/seed-infos.db" "var/chaps"

  # rsync-fast "$SSH/var/chaps/users" "var/chaps"
  rsync-fast "$SSH/var/chaps/infos" "var/chaps"

  rsync-fast "$SSH/var/texts/rgbks" "var/texts"

  rsync-fast "$SSH/var/.html" "var"
  # rsync-fast "$SSH/var/texts/rzips" "var/texts"
fi

## backup book data
if [[ $* == *misc* ]]
then
  echo backup miscs data!
  # rsync-fast "$SSH/var/texts/edits" "var/texts"
  # rsync-fast "$SSH/var/texts/trans" "var/texts"

  rsync-fast "$SSH/var/books/covers.db" "var/books"
  rsync-fast "$SSH/var/books/covers" "var/books"

fi

## backup pg_data
if [[ $1 == "all" || $* == *pgdb* ]]
then
  echo backup pg_data!
  rsync-fast --delete "nipin@ssh.chivi.app:var/wal_log" "var/.keep"
  rsync-fast --delete "nipin@ssh.chivi.app:var/pg_data" "var/.keep"
fi
