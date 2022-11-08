#!/usr/bin/env bash
set -euo pipefail

CV_ENV=development
AMBER_ENV=development

sudo service $1-srv stop
echo killed service $1-srv to start $1-srv in dev mode!

nodemon -L --watch ./src/$1 --exec "crystal run" src/$1/$1_srv.cr --error-trace

echo turn back to $1-srv service!
sudo service $1-srv start
