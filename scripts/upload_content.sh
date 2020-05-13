#! /bin/bash

INP=data
OUT=nipin@ssh.chivi.xyz:web/chivi

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_infos" "$OUT/data/vp_infos"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_lists" "$OUT/data/vp_lists"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/indexing" "$OUT/data/indexing"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/sitemaps" "$OUT/data/sitemaps"

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "web/upload" "$OUT/web/upload"
