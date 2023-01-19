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
  rsync -azi --no-p --include="*/" --exclude="*.zip" "var/chaps/texts" "$SSH/var/chaps"
fi

if [[ $* == "all" || $* == *misc* ]]
then
  echo upload misc!

  rsync-fast "var/dicts/defns" --include="*/" --exclude="*.zst" "$SSH/var/dicts"

  rsync-fast "var/dicts/spdic" "$SSH/var/dicts"

  rsync-fast "var/dicts/v1raw" "$SSH/var/dicts"
  rsync-fast "var/dicts/v1dic" "$SSH/var/dicts"

  rsync-fast "var/dicts/v2raw" "$SSH/var/dicts"
  rsync-fast "var/dicts/v2dic" "$SSH/var/dicts"
fi

echo $*

if [[ $* == "all" || $* == *mtv2* ]]
then
  echo upload mtv2!

  rsync-fast "var/mt_v2/dicts" "$SSH/var/mt_v2"
  rsync-fast "var/mt_v2/inits" "$SSH/var/mt_v2"
  rsync-fast "var/mt_v2/ptags" "$SSH/var/mt_v2"
  rsync-fast "var/mt_v2/rules" "$SSH/var/mt_v2"

  rsync-fast "var/dicts/hints" "$SSH/var/dicts"
  rsync-fast "var/dicts/qtran" "$SSH/var/dicts"

  rsync-fast "var/dicts/index.db" "$SSH/var/dicts"
  rsync-fast "var/dicts/init.dic" "$SSH/var/dicts"
  rsync-fast "var/dicts/core.dic" "$SSH/var/dicts"
  rsync-fast "var/dicts/book.dic" "$SSH/var/dicts"
fi
