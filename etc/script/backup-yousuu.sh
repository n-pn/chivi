#! /bin/bash

REMOTE=deploy@ssh.chivi.xyz:www/chivi
SEEDS_DIR=_db/seeds/yousuu
SEEDS_SSH="$REMOTE/$SEEDS_DIR"

rsync -azui --no-p "$SEEDS_SSH/raw-infos" $SEEDS_DIR
rsync -azui --no-p "$SEEDS_SSH/raw-crits" $SEEDS_DIR
