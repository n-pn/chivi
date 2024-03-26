#!/usr/bin/env bash
set -euo pipefail

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x -p 2222' $@
}

SSH=nipin@192.168.1.22:/app/chivi

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
    rsync-fast src/hanlp/hanlp-srv.py $SSH/bin
  else
    crystal build -s --release --mcpu native src/$target/$target-srv.cr -o bin/$target-srv
    rsync-fast bin/$target-srv $SSH/bin
  fi

  ssh 192.168.1.22 -p 2222 "sudo service $target restart"
done
