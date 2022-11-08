#!/usr/bin/env bash

echo "Backup from chivi.app!"

REMOTE=nipin@ssh.chivi.app
SSH=$REMOTE:/app/chivi

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup users data!
  rsync -aiz --no-p --delete "$SSH/var/_common" "var"
  rsync -aiz --no-p --delete "$SSH/var/tlspecs/users" "var/cvmtl/users"
fi

## backup dict data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!
  # rsync -aiz --no-p --exclude="*.tsv" "$SSH/var/dicts/v1/" "var/dicts/v1/"
  rsync -aiz --no-p "$SSH/var/dicts/v1/" "var/dicts/v1/"
  rsync -aiz --no-p "$SSH/var/vdict/" "var/vdict/"
fi

## backup book data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  # rsync -aiz --no-p "$SSH/var/nvinfos/autos" "var/nvinfos"

  rsync -aiz --no-p "$SSH/var/books/.html" "var/books"
  rsync -aiz --no-p "$SSH/var/books/infos" "var/books"
  rsync -aiz --no-p "$SSH/var/books/cover" "var/books"

  rsync -aiz --no-p "$SSH/var/chaps/.html" "var/chaps"
  rsync -aiz --no-p "$SSH/var/chaps/users" "var/chaps"
  rsync -aiz --no-p "$SSH/var/chaps/texts" "var/chaps"
fi

## backup crit data
if [[ $1 == "all" || $* == *seed* ]]
then
  echo backup seeds data!

  rsync -aiz --no-p "$SSH/var/fixed" "var"
fi

## backup pg_data
if [[ $1 == "all" || $* == *pg_data* ]]
then
  echo backup pg_data!
  rsync -ai --no-p --delete "$REMOTE:var/wal_log" "var/.keep"
  rsync -aiz --no-p --delete "$REMOTE:var/pg_data" "var/.keep"
  rsync -aiz --no-p --delete "$SSH/var/pg_data/weblogs/" "var/.keep/web_log/"
fi
