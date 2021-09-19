#!/usr/bin/env bash

echo "Backup from chivi.xyz!"
SSH=nipin@ssh.chivi.xyz:srv/chivi.xyz

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

  rsync -aiz --no-p "$SSH/_db/vpdict/main" "_db/vpdict/.bak/" &
  rsync -aiz --no-p "$SSH/_db/vpdict/pleb" "_db/vpdict/.bak/" &
  rsync -aiz --no-p "$SSH/_db/vpdict/logs" "_db/vpdict/.bak/" &
  rsync -aiz --no-p "$SSH/_db/vpdict/logs/" "_db/vpdict/logs/"
  rsync -aiz --no-p "$SSH/_db/vpdict/main/" "_db/vpdict/main/"
  rsync -aiz --no-p "$SSH/_db/vpdict/pleb/" "_db/vpdict/pleb/"
fi

## backup user data
if [[ $1 == "all" || $* == *book* ]]
then
  echo backup books data!
  rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
  rsync -aiz --no-p "$SSH/_db/chseed/" "_db/chseed/"
  rsync -aiz --no-p "$SSH/_db/zhbook/" "_db/zhbook/"
fi
