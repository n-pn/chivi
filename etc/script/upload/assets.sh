#! /bin/bash

INP=var
OUT=nipin@ssh.chivi.xyz:srv/chivi/var/appcv

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/dict_repos" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/book_infos" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/book_metas" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/book_metas" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/book_index" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/chap_lists" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/chap_texts" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/chap_trans" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/user_infos" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/user_crits" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/user_books" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/user_lists" $OUT

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "web/public" "$OUT/www/"
