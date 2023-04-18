#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build && rsync -ai --no-p build/ /app/chivi.app/web/
    cd ..
  # elif [[ $target == "hanlp" ]]
  # then
  #   rsync-fast "src/hanlp-srv.py" $SSH/bin
  else
    crystal build -s --release src/$target-srv.cr -o /app/chivi.app/bin/$target-srv
  fi

  echo restarting $target service
  sudo service $target-srv restart
done
