#!/usr/bin/env bash
set -euo pipefail

SSH=nipin@ssh.chivi.app:/app/chivi

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

for target in "$@"
do
  echo push $target!
  rsync-fast bin/$target $SSH/bin
done
