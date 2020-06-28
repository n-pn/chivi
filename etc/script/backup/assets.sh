#! /bin/bash

INP=nipin@ssh.chivi.xyz:web/chivi/data
OUT=assets/.prev

rsync -azui "$INP/cv_dicts" "$OUT/"
# rsync -azui "$INP/zh_texts" "$OUT/"
