#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/data/txt-inp/yousuu
OUT=assets/.init/books/yousuu

rsync -azui "$INP/serials" $OUT
rsync -azui "$INP/reviews" $OUT
