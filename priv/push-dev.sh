#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build
    rsync -ai --no-p build/ /app/chivi.dev/web/
    cd ..
  elif [[ $target == "hanlp" ]]
  then
    cp -f "src/mt_sp/hanlp_srv.py" /app/chivi.dev/bin
  else
    crystal build -s --release src/$target-srv.cr -o /app/chivi.dev/bin/$target-srv
  fi

  echo restarting $target-dev service
  sudo service $target-dev restart
done
