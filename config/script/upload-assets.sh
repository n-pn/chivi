#! /bin/bash

SSH=deploy@ssh.chivi.xyz:www/chivi

rsync -azi --exclude '*.log' "_db/cvdict/legacy" "$SSH/_db/cvdict"
rsync -azi --exclude '*.tab' "_db/cvdict/active" "$SSH/_db/cvdict"

DIR = "_db/_oldcv"

rsync -azi --no-p "$DIR/members" "$SSH/$DIR"
rsync -azi --no-p "$DIR/serials" "$SSH/$DIR"
rsync -azi --no-p "$DIR/indexes" "$SSH/$DIR"
rsync -azi --no-p "$DIR/chlists" "$SSH/$DIR"

rsync -azi --no-p "web/public" "$SSH/web"
