#!/usr/bin/env bash
set -euo pipefail

export OUT=/2tb/app.chivi

for target in "$@"
do
  echo push $target!

  if [[ $target == "webcv" ]]
  then
    cd web && pnpm run build && rsync -ai --no-p build/ $OUT/web/
    cd ..
  elif [[ $target == "appcv" ]]
  then
    crystal build -s --release src/cvapp/cvapp-srv.cr -o bin/cvapp-srv
  elif [[ $target == "hanlp" ]]
  then
    cp -f src/hanlp/hanlp-srv.py $OUT/bin
  else
    crystal build -s --release src/$target/$target-srv.cr -o $OUT/bin/$target-srv
  fi

  echo restarting $target service
  sudo service $target restart
done
