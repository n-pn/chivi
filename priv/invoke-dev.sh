#!/usr/bin/env bash
# set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G
export CV_ENV=development

TARGET=${1:-"cvapp"}
WATCH="-w ./src/$TARGET -w ./src/_data -w ./src/_util"

sudo service $TARGET-dev stop
echo killed service $TARGET-dev to start $TARGET-srv in dev mode!

nodemon $WATCH --exec "crystal run --error-trace --link-flags='-fuse-ld=mold'" src/$TARGET/$TARGET-srv.cr

echo turn back to $TARGET-srv service!
sudo service $TARGET-srv start
