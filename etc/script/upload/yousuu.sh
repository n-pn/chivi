#! /bin/bash

INP=var/appcv/.cached/yousuu
OUT=nipin@ssh.nipin.xyz:web/chivi/var/appcv/.cached/yousuu

rsync -azui "$INP/proxies/awmproxy.com.txt" "$OUT/proxies"
rsync -azui "$INP/proxies/openproxy.space.txt" "$OUT/proxies"
rsync -azui "$INP/proxies/proxyscrape.com.txt" "$OUT/proxies"

rsync -azui "$INP/serials" $OUT
rsync -azui "$INP/reviews" $OUT
