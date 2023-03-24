#!/usr/bin/env bash
set -euo pipefail

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb-srv" ]]
  then
    cd web && pnpm run build
    rsync -ai --no-p build/ /app/chivi/web/
    cd ..
  elif [[ $target == "hanlp-srv" ]]
  then
    cp -f "src/mt_sp/hanlp_srv.py" /app/chivi/bin
  else
    GC_INITIAL_HEAP_SIZE=4G shards build -s --release --production $target
  fi

  echo restarting $target service
  sudo service $target restart
done
