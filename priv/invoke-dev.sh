#!/usr/bin/env bash
set -euo pipefail

export GC_INITIAL_HEAP_SIZE=4G
export CV_ENV=development

TARGET=${1:-"cvapp"}
WATCH="--watch ./src/_util --watch ./src/$TARGET"

if [[ $TARGET == "cvapp" ]]
then
  WATCH="$WATCH --watch ./src/_data"
fi

sudo service $TARGET-dev stop
echo killed service $TARGET-dev to start $TARGET-srv in dev mode!

nodemon $WATCH --exec "crystal run -s --error-trace" src/$TARGET-srv.cr

echo turn back to $TARGET-srv service!
sudo service $TARGET-srv start
