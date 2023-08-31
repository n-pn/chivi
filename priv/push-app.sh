#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build && rsync -ai --no-p build/ /2tb/app.chivi/web/
    cd ..
  # elif [[ $target == "hanlp" ]]
  # then
  #   rsync-fast "src/hanlp-srv.py" $SSH/bin
  else
    crystal build -s --release src/$target/$target-srv.cr -o /2tb/app.chivi/bin/$target-srv
  fi

  echo restarting $target service
  sudo service $target-srv restart
done
