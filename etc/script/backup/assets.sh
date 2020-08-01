#! /bin/bash

INP_OLD=nipin@ssh.chivi.xyz:web/chivi/data
OUT_OLD=var/._old_info

rsync -azi "$INP_OLD/cv_dicts/*" "$OUT_OLD/cv_dicts"
rsync -azui "$INP/zh_texts/*" "$OUT/zh_texts"

INP=nipin@ssh.nipin.xyz:web/chivi/var/
OUT=var/

rsync -azi "$INP/dictdb" $OUT
rsync -azi "$INP/userdb" $OUT
