#! /bin/bash

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

SSH=/app/chivi.app

DIR="var/ysraw"
SSH_DIR="$SSH/$DIR"

PROXY_DIR="var/proxy"
PROXY_SSH="$SSH/$PROXY_DIR"


if [[ $1 == "all" || $* == *proxy* ]]
then
  # rsync-fast "$PROXY_DIR/awmproxy.com.txt" $PROXY_SSH
  rsync-fast "$PROXY_DIR/jetkai.github.txt" $PROXY_SSH
  rsync-fast "$PROXY_DIR/openproxy.space.txt" $PROXY_SSH
  rsync-fast "$PROXY_DIR/proxyscrape.com.txt" $PROXY_SSH

  rsync-fast "$PROXY_DIR/.works" $PROXY_SSH
fi

if [[ $1 == "all" || $* == *books* ]]
then
  echo upload book related data!

  yarn build ysbook_crawl
  rsync-fast "bin/ysbook_crawl" "$SSH/bin"

  rsync-fast "var/ysapp/books.db" $SSH/var/ysapp/books.db
  rsync-fast "$DIR/books" $SSH_DIR
fi

if [[ $1 == "all" || $* == *users* ]]
then
  echo upload book related data!

  yarn build ysbook_crawl
  rsync-fast "bin/ysbook_crawl" "$SSH/bin"

  rsync-fast "var/ysapp/users.db" $SSH/var/ysapp/users.db
  rsync-fast "$DIR/users" $SSH_DIR
fi


if [[ $1 == "all" || $* == *crits* ]]
then
  echo upload raw review jsons!

  yarn build yscrit_crawl_by_user
  rsync-fast "bin/yscrit_crawl_by_user" "$SSH/bin"

  # rsync-fast "$DIR/crits" $SSH_DIR
  rsync-fast "$DIR/crits-by-user" $SSH_DIR
  # rsync-fast "$DIR/crits-by-list" $SSH_DIR
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

if [[ $1 == "all" || $* == *miscs* ]]
then
  echo upload miscs data!
  rsync-fast "var/ysapp/repls-zip" "$SSH/var/ysapp"
fi

SRC=tasks/yousuu

if [[ $1 == "all" || $* == *execs* ]]
then
  echo upload service binaries!

  # rsync-fast "$DIR/limit.txt" $SSH_DIR

  yarn build ysbook_crawl && rsync-fast "bin/ysbook_crawl" "$SSH/bin"
  yarn build ysuser_crawl && rsync-fast "bin/ysuser_crawl" "$SSH/bin"
  yarn build ysrepl_crawl && rsync-fast "bin/ysrepl_crawl" "$SSH/bin"
  yarn build yslist_crawl && rsync-fast "bin/yslist_crawl" "$SSH/bin"

  yarn build yscrit_crawl_by_user && rsync-fast "bin/yscrit_crawl_by_user" "$SSH/bin"
  yarn build yscrit_crawl_by_book && rsync-fast "bin/yscrit_crawl_by_book" "$SSH/bin"
  yarn build yscrit_crawl_by_list && rsync-fast "bin/yscrit_crawl_by_list" "$SSH/bin"

  yarn build yslist_crawl_by_book && rsync-fast "bin/yslist_crawl_by_book" "$SSH/bin"
  yarn build yslist_crawl_by_user && rsync-fast "bin/yslist_crawl_by_user" "$SSH/bin"

fi
