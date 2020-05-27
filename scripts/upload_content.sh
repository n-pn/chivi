#! /bin/bash

INP=data
OUT=nipin@ssh.chivi.xyz:web/chivi

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/cc_cedict" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/trungviet" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/hanviet" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/hantrad" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/pinyins" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/tradsim" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/shared_base" "$OUT/data/cv_dicts"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/cv_dicts/unique_base" "$OUT/data/cv_dicts"

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/book_infos" "$OUT/data/"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/vp_lists" "$OUT/data/"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/indexing" "$OUT/data/"
rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "$INP/sitemaps" "$OUT/data/"

rsync -azi --chmod=Dg+s,ug+w,Fo-w,+X "web/upload" "$OUT/web/"
