#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var/.book_cache/yousuu
OUT=var/.book_cache/yousuu

rsync -azui "$INP/serials" $OUT
rsync -azui "$INP/reviews" $OUT
