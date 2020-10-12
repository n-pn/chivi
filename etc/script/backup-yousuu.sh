#! /bin/bash

REMOTE=nipin@ssh.nipin.xyz:web/chivi
SEEDS_DIR=_db/inits/seeds/yousuu
SEEDS_SSH="$REMOTE/$SEEDS_DIR"

rsync -azui "$SEEDS_SSH/_infos/" "$SEEDS_DIR/_infos/"
rsync -azui "$SEEDS_SSH/_crits/" "$SEEDS_DIR/_crits/"
