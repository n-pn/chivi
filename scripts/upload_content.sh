#! /bin/bash

INP=data
OUT=nipin@ssh.chivi.xyz:web/chivi/data

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts" "$OUT/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_infos" "$OUT/vp_infos"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_lists" "$OUT/vp_lists"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/indexing" "$OUT/indexing"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/sitemaps" "$OUT/sitemaps"
