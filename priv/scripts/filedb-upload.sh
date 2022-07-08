#!/usr/bin/env bash


SSH=nipin@ssh.chivi.app:srv/chivi

## upload dicts
if [[ $* == "all" || $* == *dict* ]]
then
  echo upload dicts!
  rsync -azi --no-p "var/dicts/v1/basic/fixture.tsv" "$SSH/var/dicts/v1/basic"
  rsync -azi --no-p "var/dicts/v1/basic/essence.tsv" "$SSH/var/dicts/v1/basic"

  rsync -azi --no-p --delete "var/dicts/vx" "$SSH/var/dicts"
fi

## upload parsed seed data
if [[ $* == "all" || $* == *seed* ]]
then
  echo upload seed data!
  # rsync -azi --no-p "var/nvinfos/autos" "$SSH/var/nvinfos"
  # rsync -azi --no-p "priv/static/covers/" "$SSH/priv/static/covers/"

  # rsync -azi --no-p "var/_common" "$SSH/var"

  rsync -azi --no-p "var/vpterms" "$SSH/var"
  rsync -azi --no-p "var/qttexts" "$SSH/var"
  rsync -azi --no-p "var/tlspecs" "$SSH/var"

  rsync -azi --no-p "var/zhinfos" "$SSH/var"
  rsync -azi --no-p "var/ysinfos" "$SSH/var"
  rsync -azi --no-p "var/pg_data" "$SSH/var"

  rsync -azi --no-p --exclude="*.zip" "var/chtexts/" "$SSH/var/chtexts/"
fi

if [[ $* == "all" || $* == "misc" ]]
then
  echo upload misc!
  # rsync -azi --no-p "var/dicts/v0/_init" "$SSH/var/dicts/v0"
  # rsync -azi --no-p "var/dicts/v1/basic/hanviet.tsv" "$SSH/var/dicts/v1/basic"
  # rsync -azi --no-p "var/dicts/v1/basic/hanviet.tab" "$SSH/var/dicts/v1/basic"

  # rsync -azi --no-p "var/_common" "$SSH/var"
  rsync -azi "var/dicts/vx/tlname" "$SSH/var/dicts/vx"
  # rsync -azi --exclude="*.tab" "var/dicts/v1/novel" "$SSH/var/dicts/v1"
  # rsync -azi --no-p --delete "priv/static/covers/" "$SSH/priv/static/covers/"
fi

if [[ $* == "all" || $* == "zhinfo" ]]
then
  echo upload zhinfo!

  yarn build remote_seed && rsync -azi --no-p "bin/remote_seed" "$SSH/bin"
  yarn build ysbook_seed && rsync -azi --no-p "bin/ysbook_seed" "$SSH/bin"

  rsync -azi --no-p "var/_common" "$SSH/var"
  rsync -azi --no-p "var/zhinfos" "$SSH/var"
  # rsync -azi --no-p "var/chmetas/seeds/biquyue" "$SSH/var/chmetas/seeds"
fi
