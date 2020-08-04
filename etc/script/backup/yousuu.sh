#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var/appcv/.cached/yousuu
OUT=var/appcv/.cached/yousuu

rsync -azui "$INP/serials" $OUT
rsync -azui "$INP/reviews" $OUT
