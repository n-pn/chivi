#! /bin/bash

REMOTE=nipin@ssh.chivi.app:srv/chivi.app

PROXY_DIR=_db/yousuu/_proxy
PROXY_SSH="$REMOTE/$PROXY_DIR"

rsync -azui --no-p "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
rsync -azui --no-p "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
rsync -azui --no-p "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

# SEEDS_DIR=_db/yousuu/.cache
# SEEDS_SSH="$REMOTE/$SEEDS_DIR"

# rsync -azui --no-p "$SEEDS_DIR/infos" $SEEDS_SSH
# rsync -azui --no-p "$SEEDS_DIR/crits" $SEEDS_SSH
