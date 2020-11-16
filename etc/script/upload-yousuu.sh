#! /bin/bash

REMOTE=deploy@ssh.chivi.xyz:www/chivi

PROXY_DIR=_db/prime/_proxy
PROXY_SSH="$REMOTE/$PROXY_DIR"

rsync -azui --no-p "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
rsync -azui --no-p "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
rsync -azui --no-p "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

SEEDS_DIR=_db/seeds/yousuu
SEEDS_SSH="$REMOTE/$SEEDS_DIR"

rsync -azui --no-p "$SEEDS_DIR/raw-infos" $SEEDS_SSH
rsync -azui --no-p "$SEEDS_DIR/raw-crits" $SEEDS_SSH
