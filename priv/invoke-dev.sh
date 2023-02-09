#!/usr/bin/env bash
set -euo pipefail

CV_ENV=development

TARGET=${1:-"cvapp"}
SOURCE=$TARGET
WATCH="--watch ./src/_util --watch ./src/$SOURCE"

if [[ $TARGET == "cvapp" ]]
then
  WATCH="$WATCH --watch ./src/_data"
fi

sudo service $TARGET-srv stop
echo killed service $TARGET-srv to start $TARGET-srv in dev mode!

export GC_INITIAL_HEAP_SIZE=4G
nodemon $WATCH --exec "crystal run --error-trace" src/$SOURCE/${SOURCE}_srv.cr

# echo turn back to $TARGET-srv service!
# sudo service $TARGET-srv start
