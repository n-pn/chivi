#! /bin/bash

function rsync-fast {
  rsync -aHAXxvi --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

SSH=nipin@ec2.chivi.app:chivi

DIR=var/ysraw
SSH_DIR="$SSH/$DIR"

PROXY_DIR="var/proxy"
PROXY_SSH="$SSH/$PROXY_DIR"


if [[ $1 == "all" || $* == *proxy* ]]
then
  # rsync-fast "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
  rsync-fast "$PROXY_DIR/jetkai.github.txt" $PROXY_SSH
  rsync-fast "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
  rsync-fast "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

  # rsync-fast "$PROXY_DIR/.works" $PROXY_SSH
fi

if [[ $1 == "all" || $* == *books* ]]
then
  echo upload book related data!
  yarn build ysbook_crawl && rsync-fast "bin/ysbook_crawl" "$SSH/bin"
  # rsync-fast "$DIR/books" $SSH_DIR
  # rsync-fast "var/ysapp/books.db" $SSH/var/ysapp/books.db
fi

if [[ $1 == "all" || $* == *crits* ]]
then
  echo upload raw review jsons!
  rsync-fast "$DIR/crits" $SSH_DIR
fi

if [[ $1 == "all" || $* == *repls* ]]
then
  echo upload raw reply jsons!
  rsync-fast "$DIR/repls" $SSH_DIR
fi

if [[ $1 == "all" || $* == *lists* ]]
then
  echo upload raw reply jsons!
  rsync-fast "$DIR/lists" $SSH_DIR
fi

SRC=tasks/yousuu

if [[ $1 == "all" || $* == *execs* ]]
then
  echo upload service binaries!

  # rsync-fast "$DIR/limit.txt" $SSH_DIR

  yarn build yscrit_crawl_by_book && rsync-fast "bin/yscrit_crawl_by_book" "$SSH/bin"
  yarn build yscrit_crawl_by_list && rsync-fast "bin/yscrit_crawl_by_list" "$SSH/bin"

  yarn build yslist_crawl_by_book && rsync-fast "bin/yslist_crawl_by_book" "$SSH/bin"
  yarn build yslist_crawl_by_user && rsync-fast "bin/yslist_crawl_by_user" "$SSH/bin"

  yarn build ysbook_crawl && rsync-fast "bin/ysbook_crawl" "$SSH/bin"
  yarn build ysrepl_crawl && rsync-fast "bin/ysrepl_crawl" "$SSH/bin"

  crystal build -s --release $SRC/yslist_crawl.cr -o bin/yslist_crawl
  rsync-fast "bin/yslist_crawl" "$SSH/bin"

  crystal build -s --release $SRC/ysuser_crawl.cr -o bin/ysuser_crawl
  rsync-fast "bin/ysuser_crawl" "$SSH/bin"
fi
