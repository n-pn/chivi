#!/usr/bin/env bash
set -euo pipefail

SSH=nipin@ssh.chivi.app:/app/chivi

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb-srv" ]]
  then
    cd web && pnpm run build
    rsync-fast build/ $SSH/web/
    cd ..
  # elif [[ $target == "hanlp-srv" ]]
  # then
  #   rsync-fast "src/mt_sp/hanlp_srv.py" $SSH/bin
  else
    GC_INITIAL_HEAP_SIZE=4G shards build -s --release --production $target
    rsync-fast bin/$target $SSH/bin
  fi

  ssh nipin@ssh.chivi.app "sudo service $target restart"
done
