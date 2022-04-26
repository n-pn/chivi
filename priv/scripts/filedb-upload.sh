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

  rsync -azi --no-p "var/_common" "$ssh/var"

  rsync -azi --no-p --delete "var/cvusers" "$ssh/var"
  rsync -azi --no-p --delete "var/ubmemos" "$ssh/var"

  rsync -azi --no-p "var/vpterms" "$ssh/var"
  rsync -azi --no-p "var/qttexts" "$ssh/var"
  rsync -azi --no-p "var/tlspecs" "$ssh/var"

  rsync -azi --no-p "var/zhinfos" "$ssh/var"
  rsync -azi --no-p "var/ysinfos/ysbooks" "$ssh/var/ysinfos"
  rsync -azi --no-p "var/ysinfos/yscrits" "$ssh/var/ysinfos"

  rsync -azi --no-p --exclude="*.zip" "var/chtexts/" "$ssh/var/chtexts/"
fi

if [[ $2 == "misc" ]]
then
  echo upload misc!
  # rsync -azi --no-p "var/vpdicts/v0/_init" "$ssh/var/vpdicts/v0"
  # rsync -azi --no-p "var/vpdicts/v1/basic/hanviet.tsv" "$ssh/var/vpdicts/v1/basic"
  # rsync -azi --no-p "var/vpdicts/v1/basic/hanviet.tab" "$ssh/var/vpdicts/v1/basic"

  rsync -azi --no-p "var/_common" "$ssh/var"
  rsync -azi --no-p "var/vphints" "$ssh/var"
  # rsync -azi --no-p "var/zhinfos" "$ssh/var"

  # rsync -azi --no-p --delete "priv/static/covers/" "$ssh/priv/static/covers/"
fi
