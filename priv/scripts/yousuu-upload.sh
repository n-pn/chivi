#! /bin/bash

SSH=nipin@ssh.chivi.app:srv/chivi

DIR=_db/yousuu
SSH_DIR="$SSH/$DIR"

PROXY_DIR="$DIR/_proxy"
PROXY_SSH="$SSH_DIR/_proxy"


if [[ $1 == "all" || $* == *proxy* ]]
then
  rsync -azui --no-p "$DIR/limit.txt" $SSH_DIR

  rsync -azui --no-p "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
  rsync -azui --no-p "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
  rsync -azui --no-p "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

  # rsync -azui --no-p "$PROXY_DIR/.works" $PROXY_SSH
fi

if [[ $1 == "all" || $* == *infos* ]]
then
  echo upload raw info jsons!
  rsync -azui --no-p "$DIR/infos" $SSH_DIR
fi

if [[ $1 == "all" || $* == *crits* ]]
then
  echo upload raw review jsons!
  rsync -azui --no-p "$DIR/crits" $SSH_DIR
fi

if [[ $1 == "all" || $* == *repls* ]]
then
  echo upload raw reply jsons!
  rsync -azui --no-p "$DIR/repls" $SSH_DIR
fi

if [[ $1 == "all" || $* == *lists* ]]
then
  echo upload raw reply jsons!
  rsync -azui --no-p "$DIR/lists" $SSH_DIR
fi

if [[ $1 == "all" || $* == *seeds* ]]
then
  echo upload seed data!
  rsync -azui --no-p "var/ysinfos/ysusers.tsv" "$SSH/var/ysinfos"
  rsync -azui --no-p "var/ysinfos/yscrits" "$SSH/var/ysinfos"
fi

SRC=tasks/yousuu

if [[ $1 == "all" || $* == *execs* ]]
then
  echo upload service binaries!

  rsync -azui --no-p "$DIR/limit.txt" $SSH_DIR

  crystal build --release $SRC/yscrit_crawl.cr -o bin/yscrit_crawl_by_book
  rsync -azui --no-p "bin/yscrit_crawl_by_book" "$SSH/bin"

  crystal build -s --release $SRC/yslist_books_crawl.cr -o bin/yscrit_crawl
  rsync -azui --no-p "bin/yscrit_crawl" "$SSH/bin"

  crystal build -s --release $SRC/ysbook_crawl.cr -o bin/ysbook_crawl
  rsync -azui --no-p "bin/ysbook_crawl" "$SSH/bin"

  crystal build -s --release $SRC/ysrepl_crawl.cr -o bin/ysrepl_crawl
  rsync -azui --no-p "bin/ysrepl_crawl" "$SSH/bin"

  crystal build -s --release $SRC/yslist_crawl.cr -o bin/yslist_crawl
  rsync -azui --no-p "bin/yslist_crawl" "$SSH/bin"

  crystal build -s --release $SRC/yslist_info_crawl.cr -o bin/yslist_info_crawl
  rsync -azui --no-p "bin/yslist_info_crawl" "$SSH/bin"
fi
