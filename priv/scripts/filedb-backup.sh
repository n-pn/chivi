#!/usr/bin/env bash

echo "Backup from chivi.app!"
SSH=nipin@ssh.chivi.app:srv/chivi

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup user seeds!
  rsync -aiz --no-p --delete "$SSH/var/cvusers" "var"
  rsync -aiz --no-p --delete "$SSH/var/weblogs" "var"
fi


## backup user data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!

  rsync -aiz --no-p "$SSH/var/vpdicts/v1/basic" "var/vpdicts/v1"
  rsync -aiz --no-p "$SSH/var/vpdicts/v1/novel" "var/vpdicts/v1/"
  rsync -aiz --no-p "$SSH/var/vpdicts/v1/theme" "var/vpdicts/v1/"
  rsync -aiz --no-p "$SSH/var/vpdicts/v1/cvmtl/*.tab" "var/vpdicts/v1/cvmtl"
fi

## backup user data
if [[ $1 == "all" || $* == *spec* ]]
then
  echo backup tlspecs
  rsync -aiz --no-p --delete "$SSH/var/tlspecs/users" "var/tlspecs"
fi

## backup user data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  # rsync -aiz --no-p "$SSH/var/nvinfos/autos" "var/nvinfos"

  rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
  rsync -aiz --no-p "$SSH/var/chtexts/users" "var/chtexts"
  # rsync -aiz --no-p "$SSH/var/chtexts/" "var/chtexts/"
fi

## backup crit data
if [[ $1 == "all" || $* == *seed* ]]
then
  echo backup seed data!
  rsync -aiz --no-p "$SSH/var/cvposts" "var"
  rsync -aiz --no-p "$SSH/var/cvrepls" "var"

  rsync -aiz --no-p "$SSH/var/nvseeds" "var"
  rsync -aiz --no-p "$SSH/var/ysbooks" "var"
  rsync -aiz --no-p "$SSH/var/yscrits" "var"
fi

## backup pg_data
if [[ $1 == "all" || $* == *data* ]]
then
  echo backup pg_data!
  rsync -aiz --no-p "nipin@ssh.chivi.app:var/wal_log" "var/.backup"
  # rsync -aiz --no-p "nipin@ssh.chivi.app:var/pg_data" "var/.backup"
fi
