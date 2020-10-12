#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var/appcv/.cached/yousuu
OUT=_db/inits/seeds/yousuu

rsync -azui "$INP/serials/" "$OUT/_infos/"
rsync -azui "$INP/reviews/" "$OUT/_crits/"
