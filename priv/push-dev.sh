#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build
    rsync -ai --no-p build/ /2tb/dev.chivi/web/
    cd ..
  elif [[ $target == "hanlp" ]]
  then
    cp -f "src/mt_sp/hanlp_srv.py" /2tb/dev.chivi/bin
  else
    crystal build -s --release src/$target-srv.cr -o /2tb/dev.chivi/bin/$target-srv
  fi

  echo restarting $target-dev service
  sudo service $target-dev restart
done
