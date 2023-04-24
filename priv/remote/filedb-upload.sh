#!/usr/bin/env bash

SSH=nipin@ssh.chivi.app:/app/chivi

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --compress-level=3 --checksum-choice=xxh3 --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

## upload dicts
if [[ $* == "all" || $* == *dict* ]]
then
  echo upload dicts!

  # rsync-fast "var/mtdic/users" "$SSH/var/dicts"
  rsync-fast "mtdic/fixed/defns" "$SSH/mtdic/fixed"
  rsync-fast "mtdic/fixed/inits" "$SSH/mtdic/fixed"
  rsync-fast "mtdic/fixed/v1_init.dic" "$SSH/mtdic/fixed"
fi

## upload parsed seed data
if [[ $* == *seed* ]]
then
  echo upload seed data!

  # rsync-fast "/mnt/vault/image/chinfos.btrfs" "nipin@ssh.chivi.app:/app/image"

  rsync-fast "var/chaps/seed-infos.db" "$SSH/var/chaps"
  # rsync-fast "var/chaps/infos" "$SSH/var/chaps"
fi

if [[ $* == *misc* ]]
then
  echo upload misc!

  rsync-fast "var/_conf" "$SSH/var"


fi

echo $*

if [[ $* == *mtv2* ]]
then
  echo upload mtv2!

  rsync-fast "var/mt_v2/dicts" "$SSH/var/mt_v2"
  rsync-fast "var/mt_v2/inits" "$SSH/var/mt_v2"
  rsync-fast "var/mt_v2/ptags" "$SSH/var/mt_v2"
  rsync-fast "var/mt_v2/rules" "$SSH/var/mt_v2"

fi

## upload parsed seed data
if [[ $* == *text* ]]
then
  echo upload text data!
  rsync-fast "var/texts/rgbks/@*" "$SSH/var/texts/rgbks"
fi
