#!/usr/bin/env bash
set -euo pipefail

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x' $@
}

SSH=nipin@new.chivi.app:/app/chivi

for target in "$@"
do
  echo push $target!

  if [[ $target == "cvweb" ]]
  then
    cd web && pnpm run build
    rsync-fast build/ $SSH/web/
    cd ..
  elif [[ $target == "hanlp" ]]
  then
    rsync-fast src/hanlp/hanlp-srv.py $SSH/../hanlp
  else
    crystal build -s --release src/$target/$target-srv.cr -o bin/$target-srv
    rsync-fast bin/$target-srv $SSH/bin
  fi

  # echo restarting $target service
  # sudo service $target-srv restart
done
