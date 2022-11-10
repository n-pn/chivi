#!/usr/bin/env bash
set -euo pipefail

GC_INITIAL_HEAP_SIZE=3G

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
    cp -f "src/cvhlp/hanlp_srv.py" /app/chivi/bin
  else
    shards build -s --release --production $target
  fi

  sudo service $target restart
done
