#!/usr/bin/env bash
set -euo pipefail

NAME=${1:-"cvapp"}
ENV=${1:-"dev"}

if [[ $ENV == "prod" ]]
then
  ssh nipin@ssh.chivi.app \"sudo service $NAME-srv restart\"
else
  sudo service $NAME-srv restart
fi
