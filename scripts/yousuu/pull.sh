#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/data/txt-inp/yousuu
OUT=data/txt-inp/yousuu

rsync -azui --no-p "$INP/serials" "$OUT/serials"
