#! /bin/bash

DIR=_db/yousuu
SSH=nipin@ssh.chivi.app:srv/chivi.app

rsync -azui --no-p "$SSH/$DIR/infos" "$DIR"
rsync -azui --no-p "$SSH/$DIR/crits" "$DIR"
rsync -azui --no-p "$SSH/$DIR/repls" "$DIR"

rsync -azui --no-p "$SSH/var/yousuu/yscrits" "var/yousuu"
# rsync -azui --no-p "$SSH/$DIR/crits.old" "$DIR"
