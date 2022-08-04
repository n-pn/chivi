#!/usr/bin/env bash

echo "Backup from chivi.app!"
SSH=nipin@ssh.chivi.app:srv/chivi

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup users data!
  rsync -aiz --no-p --delete "$SSH/var/_common" "var"
  rsync -aiz --no-p --delete "$SSH/var/pg_data/" "var/pg_data/"
  rsync -aiz --no-p --delete "$SSH/var/tlspecs/users" "var/tlspecs"
fi

## backup dict data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!

  rsync -aiz --no-p --include="*.tab" "$SSH/var/dicts/v1/basic" "var/dicts/v1"
  rsync -aiz --no-p --include="*.tab" "$SSH/var/dicts/v1/novel" "var/dicts/v1"
  rsync -aiz --no-p --include="*.tab" "$SSH/var/dicts/v1/cvmtl" "var/dicts/v1"
  rsync -aiz --no-p --include="*.tab" "$SSH/var/dicts/v1/theme" "var/dicts/v1"
fi

## backup book data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  # rsync -aiz --no-p "$SSH/var/nvinfos/autos" "var/nvinfos"

  rsync -aiz --no-p "$SSH/var/books/.html" "var/books"
  rsync -aiz --no-p "$SSH/var/books/infos" "var/books"
  rsync -aiz --no-p "$SSH/var/books/cover" "var/books"

  rsync -aiz --no-p "$SSH/var/chtexts/@*" "var/chtexts"
  # rsync -aiz --no-p "$SSH/var/chtexts/*/*.tsv" "var/chtexts"

  rsync -aiz --no-p "$SSH/var/chaps/.html" "var/chaps"
  rsync -aiz --no-p "$SSH/var/chaps/users" "var/chaps"
fi

## backup crit data
if [[ $1 == "all" || $* == *seed* ]]
then
  echo backup seeds data!

  rsync -aiz --no-p "$SSH/var/zhinfos" "var"
  rsync -aiz --no-p "$SSH/var/ysinfos" "var"
fi

## backup pg_data
if [[ $1 == "all" || $* == *pg_data* ]]
then
  echo backup pg_data!
  rsync -aiz --no-p --delete "nipin@ssh.chivi.app:var/wal_log" "var/.backup"
  rsync -aiz --no-p --delete "nipin@ssh.chivi.app:var/pg_data" "var/.backup"
fi
