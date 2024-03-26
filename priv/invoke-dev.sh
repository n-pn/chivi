#!/usr/bin/env bash
# set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G
export CV_ENV=production
# export LOG_LEVEL=debug

TARGET=${1:-"cvapp"}
WATCH="-w ./src/$TARGET -w ./src/_data -w ./src/_util"

sudo service $TARGET stop
echo killed service $TARGET to start $TARGET in dev mode!

nodemon $WATCH --exec "crystal run -O2 --error-trace --link-flags='-fuse-ld=mold'" src/$TARGET/$TARGET-srv.cr

echo turn back to $TARGET service!
sudo service $TARGET start
