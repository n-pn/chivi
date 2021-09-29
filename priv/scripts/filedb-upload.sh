#!/usr/bin/env bash

if [[ "$1" == "prod" ]]
then
  echo "Upload to chivi.app!"
  ssh=nipin@ssh.chivi.app:srv/chivi.app
else
  echo "Upload to dev.chivi.app!"
  ssh=nipin@dev.chivi.app:srv/chivi.app
fi

## upload user data
if [[ $2 == "user"  ]]
then
  echo upload user seeds!
  rsync -azi --no-p --delete "db/seeds/users" "$ssh/db/seeds"
fi

## upload dicts
if [[ $2 == "all" || $* == *dict* ]]
then
  echo upload dicts!
  rsync -azi --no-p "_db/vpdict/pleb" "$ssh/_db/vpdict/"
  rsync -azi --no-p "_db/vpdict/logs" "$ssh/_db/vpdict/"
  rsync -azi --no-p "_db/vpdict/main" "$ssh/_db/vpdict/"
  # rsync -azi --no-p "_db/vpdict/.bak" "$ssh/_db/vpdict/" &
fi

## upload parsed seed data
if [[ $2 == "all" || $* == *seed* ]]
then
  echo upload seed data!
  rsync -azi --no-p "_db/zhbook/" "$ssh/_db/zhbook/"
  rsync -azi --no-p "priv/static/covers/" "$ssh/priv/static/covers/"
  # rsync -azi --no-p --exclude='*.zip' "_db/chseed/" "$ssh/_db/chseed/"
fi

## upload parsed seed data
if [[ $2 == "fixes"  ]]
then
  echo quickfix fixes!
  # rsync -azi --no-p "_db/.cache/bxwxorg/infos" "$ssh/_db/.cache/bxwxorg"
  # rsync -azi --no-p "_db/.cache/paoshu8/infos" "$ssh/_db/.cache/paoshu8"
  rsync -azi --no-p "_db/zhbook/zxcs_me" "$ssh/_db/zhbook/"
fi

## upload old data
# rsync -azi --no-p "_db/nv_infos/chseeds" "$ssh/_db/nv_infos/"
# rsync -azi --no-p "_db/nv_infos/update.tsv" "$ssh/_db/nv_infos/"
# rsync -azi --no-p "_db/nv_infos/access.tsv" "$ssh/_db/nv_infos/"
# rsync -azi --no-p "_db/nv_infos/access.tsv" "$ssh/_db/nv_infos/"
