#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz
DIR=_db/.cache/yousuu

rsync -azui --no-p "$SSH/$DIR/infos" $DIR
# rsync -azui --no-p "$SSH/$DIR/crits" $DIR
rsync -azui --no-p "$SSH/_db/_proxy/.works" "_db/_proxy"
