#! /bin/bash

DIR=_db/yousuu
SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -azui --no-p "$SSH/$DIR/_proxy/.works" "$DIR/_proxy"
rsync -azui --no-p "$SSH/$DIR/.cache/infos" "$DIR/.cache"
# rsync -azui --no-p "$SSH/$DIR/.cache/crits" "$DIR/.cache"
