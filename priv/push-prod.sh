#!/usr/bin/env bash
set -euo pipefail

SSH=nipin@ssh.chivi.app:srv/chivi
GC_INITIAL_HEAP_SIZE=3G

for var in "$@"
do
  echo push $var!

  if [[ $var == "svkit" ]]
  then
    cd web && pnpm i && pnpm run build
    rsync -azi --no-p build nipin@ssh.chivi.app:srv/chivi/web
    ssh nipin@ssh.chivi.app "sudo service chivi-web restart"
    cd ..
    continue
  fi

  shards build -s --release --production $var
  rsync -aiz --no-p bin/$var $SSH/bin

  case $var in
    chivi-srv | ysapp-srv | cvmtl-srv)
    ssh nipin@ssh.chivi.app "sudo service $var restart"
  esac
done
