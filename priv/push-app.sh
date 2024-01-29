#!/usr/bin/env bash
set -euo pipefail

export OUT=/2tb/app.chivi

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build && rsync -ai --no-p build/ $OUT/web/
    cd ..
  elif [[ $target == "hanlp" ]]
  then
    cp -f src/hanlp/hanlp-srv.py $OUT/bin
  else
    crystal build -s --release --mcpu native src/$target/$target-srv.cr -o $OUT/bin/$target-srv
  fi

  echo restarting $target service
  sudo service $target-srv restart
done
