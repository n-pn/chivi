#!/usr/bin/env bash

if [[ "$1" == "prod" ]]
then
  echo "Upload to chivi.app!"
  ssh=nipin@ssh.chivi.app:srv/chivi
else
  echo "Upload to dev.chivi.app!"
  ssh=nipin@dev.chivi.app:srv/chivi
fi

## upload dicts
if [[ $2 == "all" || $* == *dict* ]]
then
  echo upload dicts!
  rsync -azi --no-p "var/vpdicts/v2" "$ssh/var/vpdicts"
fi

## upload parsed seed data
if [[ $2 == "all" || $* == *seed* ]]
then
  echo upload seed data!
  # rsync -azi --no-p "var/nvinfos/autos" "$ssh/var/nvinfos"
  # rsync -azi --no-p "priv/static/covers/" "$ssh/priv/static/covers/"

  rsync -azi --no-p "var/cvusers" "$ssh/var"
  rsync -azi --no-p "var/vpterms" "$ssh/var"
  rsync -azi --no-p "var/qttexts" "$ssh/var"
  rsync -azi --no-p "var/tlspecs" "$ssh/var"

  # rsync -azi --no-p "_db/yousuu/infos" "$ssh/_db/yousuu"
  # rsync -azi --no-p "_db/yousuu/crits" "$ssh/_db/yousuu"
  # rsync -azi --no-p "_db/yousuu/repls" "$ssh/_db/yousuu"
fi

## upload parsed seed data
if [[ $2 == "fixes" ]]
then
  echo upload fixes!
  # rsync -azi --no-p "_db/.cache/bxwxorg/infos" "$ssh/_db/.cache/bxwxorg"
  # rsync -azi --no-p "_db/.cache/paoshu8/infos" "$ssh/_db/.cache/paoshu8"
  rsync -azi --no-p --exclude="*.zip" "var/chtexts/" "$ssh/var/chtexts/"
fi
