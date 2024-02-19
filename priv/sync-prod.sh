#!/usr/bin/env bash
set -euo pipefail

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x -p 22222' $@
}

SSH=nipin@192.168.1.22:/app/chivi

echo sync $1 to $2!
rsync-fast $1 $SSH/$2
