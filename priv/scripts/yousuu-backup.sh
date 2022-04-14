#! /bin/bash

DIR=_db/yousuu
SSH=nipin@ssh.chivi.app:srv/chivi

rsync -azui --no-p "$SSH/$DIR/infos" "$DIR"
rsync -azui --no-p "$SSH/$DIR/crits" "$DIR"
rsync -azui --no-p "$SSH/$DIR/repls" "$DIR"
rsync -azui --no-p "$SSH/$DIR/lists" "$DIR"

# rsync -azui --no-p "$SSH/var/ysinfos" "var"
