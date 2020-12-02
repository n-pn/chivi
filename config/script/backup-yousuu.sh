#! /bin/bash

SSH=deploy@ssh.chivi.xyz:www/chivi
DIR=_db/.cache/yousuu

rsync -azui --no-p "$SSH/$DIR/infos" $DIR
rsync -azui --no-p "$SSH/$DIR/crits" $DIR
