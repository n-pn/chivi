#! /bin/bash

SSH=deploy@ssh.chivi.xyz:www/chivi

# rsync -azi --no-p "var/libcv/lexicon" "$SSH/var/libcv"
rsync -azi --exclude '*.log' "_db/cvdict/legacy" "$SSH/db/cvdict"

DIR = "_db/_oldcv"

rsync -azi --no-p "$DIR/members" "$SSH/$DIR"
rsync -azi --no-p "$DIR/serials" "$SSH/$DIR"
rsync -azi --no-p "$DIR/indexes" "$SSH/$DIR"
rsync -azi --no-p "$DIR/chlists" "$SSH/$DIR"

rsync -azi --no-p "web/public" "$SSH/web"
