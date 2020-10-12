#! /bin/bash

REMOTE=nipin@ssh.nipin.xyz:web/chivi
PROXY_DIR=_db/prime/proxies
PROXY_SSH="$REMOTE/$PROXY_DIR"

rsync -azui "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
rsync -azui "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
rsync -azui "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

SEEDS_DIR=_db/inits/seeds/yousuu
SEEDS_SSH="$REMOTE/$SEEDS_DIR"

rsync -azui "$SEEDS_DIR/_infos/" "$SEEDS_SSH/_infos/"
rsync -azui "$SEEDS_DIR/_crits/" "$SEEDS_SSH/_crits/"
