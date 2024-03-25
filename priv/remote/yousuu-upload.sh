#! /bin/bash

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

OUT=/2tb/app.chivi

YSRAW_DIR="/srv/chivi/.keep/yousuu"
YSRAW_OUT="$OUT/$YSRAW_DIR"


if [[ $1 == "all" || $* == *proxy* ]]
then
  PROXY_DIR="var/_conf/proxy"
  PROXY_OUT="$OUT/$PROXY_DIR"

  # rsync-fast "$PROXY_DIR/awmproxy.com.txt" $PROXY_OUT
  rsync-fast "$PROXY_DIR/jetkai.github.txt" $PROXY_OUT
  rsync-fast "$PROXY_DIR/openproxy.space.txt" $PROXY_OUT
  rsync-fast "$PROXY_DIR/proxyscrape.com.txt" $PROXY_OUT

  rsync-fast "$PROXY_DIR/.works" $PROXY_OUT
fi

if [[ $1 == "all" || $* == *books* ]]
then
  echo upload book related data!

  yarn build ysbook_info-sync
  rsync-fast "bin/ysbook_info-sync" "$OUT/bin"

  rsync-fast "var/zroot/ysbooks.db3" $OUT/var/zroot
  rsync-fast "$YSRAW_DIR/books" $YSRAW_OUT
fi


if [[ $1 == "all" || $* == *crits* ]]
then
  echo upload raw review jsons!

  yarn build yscrit_crawl_by_user
  rsync-fast "bin/yscrit_crawl_by_user" "$OUT/bin"

  # rsync-fast "$DIR/crits" $OUT_DIR
  rsync-fast "$DIR/crits-by-user" $OUT_DIR
  # rsync-fast "$DIR/crits-by-list" $OUT_DIR
fi

if [[ $1 == "all" || $* == *repls* ]]
then
  echo upload raw reply jsons!
  rsync-fast "$DIR/repls" $OUT_DIR
fi

if [[ $1 == "all" || $* == *lists* ]]
then
  echo upload raw reply jsons!
  rsync-fast "$DIR/lists" $OUT_DIR
fi

if [[ $1 == "all" || $* == *miscs* ]]
then
  echo upload miscs data!
  rsync-fast "var/ysapp/repls-zip" "$OUT/var/ysapp"
fi

if [[ $1 == "all" || $* == *execs* ]]
then
  echo upload service binaries!

  yarn build ysbook_crawl && rsync-fast "bin/ysbook_crawl" "$OUT/bin"
  yarn build ysuser_crawl && rsync-fast "bin/ysuser_crawl" "$OUT/bin"
  yarn build ysrepl_crawl && rsync-fast "bin/ysrepl_crawl" "$OUT/bin"
  yarn build yslist_crawl && rsync-fast "bin/yslist_crawl" "$OUT/bin"

  yarn build yscrit_crawl_by_user && rsync-fast "bin/yscrit_crawl_by_user" "$OUT/bin"
  yarn build yscrit_crawl_by_book && rsync-fast "bin/yscrit_crawl_by_book" "$OUT/bin"
  yarn build yscrit_crawl_by_list && rsync-fast "bin/yscrit_crawl_by_list" "$OUT/bin"

  yarn build yslist_crawl_by_book && rsync-fast "bin/yslist_crawl_by_book" "$OUT/bin"
  yarn build yslist_crawl_by_user && rsync-fast "bin/yslist_crawl_by_user" "$OUT/bin"

  yarn build fix_yscrits_vhtml && rsync-fast "bin/fix_yscrits_vhtml" "$OUT/bin"
  yarn build fix_ysrepls_vhtml && rsync-fast "bin/fix_ysrepls_vhtml" "$OUT/bin"
fi
