#!/usr/bin/env bash

echo "Backup from chivi.app!"
SSH=nipin@ssh.chivi.app:srv/chivi.app

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup user seeds!
  rsync -aiz --no-p --delete "$SSH/var/pg_data/cvusers" "var/pg_data"
fi

## backup user data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!

  rsync -aiz --no-p "$SSH/var/vpdicts/basic" "var/vpdicts"
  rsync -aiz --no-p "$SSH/var/vpdicts/novel" "var/vpdicts"
  rsync -aiz --no-p "$SSH/var/vpdicts/theme" "var/vpdicts"
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
  rsync -aiz --no-p "$SSH/var/nvinfos/autos" "var/nvinfos"
  rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
  rsync -aiz --no-p "$SSH/var/chtexts/" "var/chtexts/"
fi

## backup crit data
if [[ $1 == "all" || $* == *crit* ]]
then
  echo backup reviews data!
  rsync -aiz --no-p "$SSH/var/yousuu/yscrits" "var/yousuu"
fi
