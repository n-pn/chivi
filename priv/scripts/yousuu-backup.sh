#! /bin/bash

DIR=_db/yousuu
SSH=nipin@ssh.chivi.app:srv/chivi

rsync -azui --no-p "$SSH/$DIR/infos" "$DIR"
rsync -azui --no-p "$SSH/$DIR/users" "$DIR"

rsync -azui --no-p "$SSH/$DIR/lists" "$DIR"
rsync -azui --no-p "$SSH/$DIR/lists-by-page" "$DIR"

rsync -azui --no-p "$SSH/$DIR/lists-by-book" "$DIR"
rsync -azui --no-p "$SSH/$DIR/lists-by-user" "$DIR"

rsync -azui --no-p "$SSH/$DIR/crits" "$DIR"
rsync -azui --no-p "$SSH/$DIR/crits-by-list" "$DIR"
# rsync -azui --no-p "$SSH/$DIR/crits-by-user" "$DIR"

rsync -azui --no-p "$SSH/$DIR/repls" "$DIR"
