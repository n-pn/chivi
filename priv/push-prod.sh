#!/usr/bin/env bash
set -euo pipefail

SSH=nipin@ssh.chivi.app:/app/chivi
GC_INITIAL_HEAP_SIZE=3G

function rsync-fast {
  rsync -aHAXxvi --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb-srv" ]]
  then
    cd web && pnpm run build
    rsync-fast build/ $SSH/web/
    cd ..
  elif [[ $target == "hanlp-srv" ]]
  then
    rsync-fast "src/cvhlp/hanlp_srv.py" $SSH/bin
  else
    shards build -s --release --production $target
    rsync-fast bin/$target $SSH/bin
  fi

  ssh nipin@ssh.chivi.app "sudo service $target restart"
done
