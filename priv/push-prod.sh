#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build
    rsync-fast build/ $SSH/web/
    cd ..
  # elif [[ $target == "hanlp" ]]
  # then
  #   rsync-fast "src/hanlp-srv.py" $SSH/bin
  else
    # shards build -s --release --production $target
    crystal build -s --release src/$target-srv.cr -o /app/chivi/bin/$target-srv
  fi

  echo restarting $target service
  sudo service $target-srv restart
done
