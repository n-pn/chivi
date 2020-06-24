#! /bin/bash

INP=data
OUT=nipin@ssh.chivi.xyz:web/chivi

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/cv_dicts" "$OUT/data/"
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/vp_infos" "$OUT/data/"
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/vp_lists" "$OUT/data/"
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/indexing" "$OUT/data/"
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/sitemaps" "$OUT/data/"

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "web/upload" "$OUT/web/"
