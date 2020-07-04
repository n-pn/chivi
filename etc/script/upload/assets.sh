#! /bin/bash

INP=var
OUT=nipin@ssh.chivi.xyz:srv/chivi/var/appcv

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/libcv" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/book_infos" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/book_metas" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/book_metas" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/book_index" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/chap_lists" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/chap_texts" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/chap_trans" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/user_infos" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/user_crits" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/user_books" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/appcv/user_lists" $OUT

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "web/public" "$OUT/www/"
