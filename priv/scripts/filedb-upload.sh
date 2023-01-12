#!/usr/bin/env bash

SSH=nipin@ssh.chivi.app:/app/chivi

function rsync-fast {
  rsync -aHAXxvi --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

## upload dicts
if [[ $* == "all" || $* == *dict* ]]
then
  echo upload dicts!
  rsync-fast "var/dicts/*.dic" "$SSH/var/dicts"
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
  # rsync-fast "var/dicts/v1/basic/hanviet.tsv" "$SSH/var/dicts/v1/basic"
  # rsync-fast "var/dicts/v1/basic/hanviet.tab" "$SSH/var/dicts/v1/basic"

  # rsync-fast "var/fixed" "$SSH/var"
  # rsync-fast "var/dicts/hints" "$SSH/var/dicts"
  # rsync-fast "var/cvmtl/inits" "$SSH/var/cvmtl"
  # rsync-fast "var/dicts/v1/novel" "$SSH/var/dicts/v1"
  # rsync-fast --delete "priv/static/covers/" "$SSH/priv/static/covers/"

fi

echo $*

if [[ $* == "all" || $* == *mtv2* ]]
then
  echo upload mtv2!

  rsync-fast "var/cvmtl/dicts" "$SSH/var/cvmtl"
  rsync-fast "var/cvmtl/inits" "$SSH/var/cvmtl"
  rsync-fast "var/cvmtl/ptags" "$SSH/var/cvmtl"
  rsync-fast "var/cvmtl/rules" "$SSH/var/cvmtl"

  rsync-fast "var/dicts/hints" "$SSH/var/dicts"
  rsync-fast "var/dicts/qtran" "$SSH/var/dicts"

  rsync-fast "var/dicts/index.db" "$SSH/var/dicts"
  rsync-fast "var/dicts/init.dic" "$SSH/var/dicts"
  rsync-fast "var/dicts/core.dic" "$SSH/var/dicts"
  rsync-fast "var/dicts/book.dic" "$SSH/var/dicts"
fi
