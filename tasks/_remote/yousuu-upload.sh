#! /bin/bash

REMOTE=nipin@ssh.chivi.xyz:www/chivi.xyz

PROXY_DIR=_db/_proxy
PROXY_SSH="$REMOTE/$PROXY_DIR"

rsync -azui --no-p "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
rsync -azui --no-p "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
rsync -azui --no-p "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

SEEDS_DIR=_db/.cache/yousuu
SEEDS_SSH="$REMOTE/$SEEDS_DIR"

rsync -azui --no-p "$SEEDS_DIR/infos" $SEEDS_SSH
rsync -azui --no-p "$SEEDS_DIR/crits" $SEEDS_SSH
