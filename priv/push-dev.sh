#!/usr/bin/env bash
set -euo pipefail

export OUT=/2tb/dev.chivi

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build && rsync -ai --no-p build/ $OUT/web/
    cd ..
  else
    crystal build -s --release --mcpu native src/$target/$target-srv.cr -o $OUT/bin/$target-srv
  fi

  echo restarting $target-dev service
  sudo service $target-dev restart
done
