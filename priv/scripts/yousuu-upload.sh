#! /bin/bash

REMOTE=nipin@ssh.chivi.app:srv/chivi

PROXY_DIR=_db/yousuu/_proxy
PROXY_SSH="$REMOTE/$PROXY_DIR"
SEEDS_DIR=_db/yousuu
SEEDS_SSH="$REMOTE/$SEEDS_DIR"
EXECS_DIR="$REMOTE/srv"

if [[ $1 == "all" || $* == *proxy* ]]
then
  echo upload proxies!

  rsync -azui --no-p "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
  rsync -azui --no-p "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
  rsync -azui --no-p "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH
fi

if [[ $1 == "all" || $* == *infos* ]]
then
  echo upload raw info jsons!
  rsync -azui --no-p "$SEEDS_DIR/infos" $SEEDS_SSH
fi

if [[ $1 == "all" || $* == *crits* ]]
then
  echo upload raw review jsons!
  rsync -azui --no-p "$SEEDS_DIR/crits" $SEEDS_SSH
fi

if [[ $1 == "all" || $* == *repls* ]]
then
  echo upload raw reply jsons!
  rsync -azui --no-p "$SEEDS_DIR/repls" $SEEDS_SSH
fi

if [[ $1 == "all" || $* == *execs* ]]
then
  echo upload service binaries!

  shards build --release ys_info_cr && rsync -azui --no-p "bin/ys_info_cr" $EXECS_DIR
  shards build --release ys_crit_cr && rsync -azui --no-p "bin/ys_crit_cr" $EXECS_DIR
  shards build --release ys_repl_cr && rsync -azui --no-p "bin/ys_repl_cr" $EXECS_DIR
fi

# rsync -azui --no-p "var/yousuu/yscrits" "$REMOTE/var/yousuu"
