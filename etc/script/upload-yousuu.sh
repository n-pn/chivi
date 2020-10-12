#! /bin/bash

INP=_db/inits/seeds/yousuu
OUT=nipin@ssh.nipin.xyz:web/chivi/var/appcv/.cached/yousuu

rsync -azui "_db/prime/proxies/awmproxy.com.txt" "$OUT/proxies"
rsync -azui "_db/prime/proxies/openproxy.space.txt" "$OUT/proxies"
rsync -azui "_db/prime/proxies/proxyscrape.com.txt" "$OUT/proxies"

rsync -azui "$INP/_infos/" "$OUT/serials/"
rsync -azui "$INP/_crits/" "$OUT/reviews/"
