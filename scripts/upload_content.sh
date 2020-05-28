#! /bin/bash

INP=data
OUT=nipin@ssh.chivi.xyz:web/chivi

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts" "$OUT/data/"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_infos" "$OUT/data/"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_lists" "$OUT/data/"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/indexing" "$OUT/data/"
# rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/sitemaps" "$OUT/data/"

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "web/upload" "$OUT/web/"
