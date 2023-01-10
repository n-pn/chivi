#!/usr/bin/env bash
set -euo pipefail

CV_ENV=development
AMBER_ENV=development

sudo service $1-srv stop
echo killed service $1-srv to start $1-srv in dev mode!

if [[ $1 == "cvapp" ]]
then
nodemon -L --watch ./src/webcv --exec "crystal run" src/webcv/webcv_srv.cr --error-trace
else
nodemon -L --watch ./src/$1 --exec "crystal run" src/$1/$1_srv.cr --error-trace
fi

echo turn back to $1-srv service!
sudo service $1-srv restart
