#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G

for target in "$@"
do
  shards build -s --release $target && cp -f bin/$target /2tb/app.chivi/bin
done
