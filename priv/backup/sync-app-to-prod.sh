#!/usr/bin/env bash

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x -p 22222' $@
}

DIR=/2tb/app.chivi/_db/.bak/2024-03-13
sudo chmod -R 0755 $DIR

SSH=192.168.1.22:/var/lib/postgresql/16/main/
rsync-fast $DIR $SSH
