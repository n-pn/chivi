#!/usr/bin/env bash

if [[ "$1" == "prod" ]]
then
  echo "Upload to chivi.xyz!"
  ssh=nipin@ssh.chivi.xyz:srv/chivi.xyz
else
  echo "Upload to dev.chivi.xyz!"
  ssh=nipin@dev.chivi.xyz:srv/chivi.xyz
fi

## upload user data
if [[ "$*" == *user* ]]
then
  rsync -azi --no-p "_db/vi_users/" "$ssh/_db/vi_users/"
fi

## upload dicts
if [[ $2 == "all" || $* == *dict* ]]
then
  echo upload dicts!
  rsync -azi --no-p "_db/vpdict/pleb" "$ssh/_db/vpdict/" &
  rsync -azi --no-p "_db/vpdict/logs" "$ssh/_db/vpdict/" &
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

## upload old data
# rsync -azi --no-p "_db/nv_infos/chseeds" "$ssh/_db/nv_infos/"
# rsync -azi --no-p "_db/nv_infos/update.tsv" "$ssh/_db/nv_infos/"
# rsync -azi --no-p "_db/nv_infos/access.tsv" "$ssh/_db/nv_infos/"
# rsync -azi --no-p "_db/nv_infos/access.tsv" "$ssh/_db/nv_infos/"
