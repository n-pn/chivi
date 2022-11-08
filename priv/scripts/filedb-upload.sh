#!/usr/bin/env bash

SSH=nipin@ssh.chivi.app:/app/chivi

## upload dicts
if [[ $* == "all" || $* == *dict* ]]
then
  echo upload dicts!
  rsync -azi --no-p "var/dicts/*.dic" "$SSH/var/dicts"
fi

## upload parsed seed data
if [[ $* == "all" || $* == *seed* ]]
then
  echo upload seed data!
  # rsync -azi --no-p "var/nvinfos/autos" "$SSH/var/nvinfos"
  # rsync -azi --no-p "priv/static/covers/" "$SSH/priv/static/covers/"

  rsync -azi --no-p "var/chaps/infos" "$SSH/var/chaps"
  rsync -azi --no-p --exclude="*.zip" "var/chaps/texts" "$SSH/var/chaps"
fi

if [[ $* == "all" || $* == *misc* ]]
then
  echo upload misc!
  # rsync -azi --no-p "var/dicts/v1/basic/hanviet.tsv" "$SSH/var/dicts/v1/basic"
  # rsync -azi --no-p "var/dicts/v1/basic/hanviet.tab" "$SSH/var/dicts/v1/basic"

  rsync -azi --no-p "var/fixed" "$SSH/var"
  rsync -azi --no-p "var/cvhlp" "$SSH/var"
  # rsync -azi --exclude="*.tab" "var/dicts/v1/novel" "$SSH/var/dicts/v1"
  # rsync -azi --no-p --delete "priv/static/covers/" "$SSH/priv/static/covers/"
fi

echo $*

if [[ $* == "all" || $* == *mtv2* ]]
then
  echo upload mtv2!

  rsync -azi --no-p "var/cvmtl/inits" "$SSH/var/cvmtl"
  rsync -azi --no-p "var/cvmtl/fixed" "$SSH/var/cvmtl"
  rsync -azi --no-p "var/dicts/qtran" "$SSH/var/dicts"
  rsync -azi --no-p "var/dicts/core.dic" "$SSH/var/dicts"
  rsync -azi --no-p "var/dicts/book.dic" "$SSH/var/dicts"
  rsync -azi --no-p "var/dicts/pack.dic" "$SSH/var/dicts"
fi
