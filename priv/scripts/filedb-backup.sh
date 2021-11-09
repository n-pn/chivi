#!/usr/bin/env bash

echo "Backup from chivi.app!"
SSH=nipin@ssh.chivi.app:srv/chivi.app

## backup user data
if [[ $1 == "all" || $* == *user* ]]
then
  echo backup user seeds!
  rsync -aiz --no-p --delete "$SSH/db/seeds/users" "db/seeds"
fi

## backup user data
if [[ $1 == "all" || $* == *dict* ]]
then
  echo backup dicts data!

  rsync -aiz --no-p "$SSH/db/vpdicts/core" "_db/vpdict"
  rsync -aiz --no-p "$SSH/db/vpdicts/uniq" "_db/vpdict"

  rsync -aiz --no-p "$SSH/var/vpdicts/core" "var/vpdicts"
  rsync -aiz --no-p "$SSH/var/vpdicts/uniq" "var/vpdicts"
fi

## backup user data
if [[ $1 == "all" || $* == *spec* ]]
then
  echo backup tlspecs
  rsync -aiz --no-p --delete "$SSH/db/tlspecs" "db"
fi

## backup user data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
  rsync -aiz --no-p "$SSH/_db/zhbook/" "_db/zhbook/"
  rsync -aiz --no-p "$SSH/db/chtexts/" "db/chtexts/"
fi

## backup crit data
if [[ $1 == "all" || $* == *crit* ]]
then
  echo backup reviews data!
  rsync -aiz --no-p "$SSH/var/yousuu/yscrits" "var/yousuu"
fi
