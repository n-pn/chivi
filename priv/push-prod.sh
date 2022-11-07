#!/usr/bin/env bash
set -euo pipefail

SSH=nipin@ssh.chivi.app:/app/chivi
GC_INITIAL_HEAP_SIZE=3G

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb-srv" ]]
  then
    cd web && pnpm run build
    rsync -ai --no-p build/ $SSH/web/
    cd ..
  else
    shards build -s --release --production $target
    rsync -aiz --no-p bin/$target $SSH/bin
  fi

  ssh nipin@ssh.chivi.app "sudo service $target restart"
done
