#! /bin/bash

# INP=var
# OUT=nipin@ssh.chivi.xyz:srv/chivi/var/appcv

# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/dictdb" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/bookdb" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/chapdb" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/lookup" $OUT
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "$INP/userdb" $OUT

# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "web/public" "$OUT/www/"

INP=var/._old_info
OUT=nipin@ssh.chivi.xyz:web/chivi/data

rsync -azui "$INP/cv_dicts" "$OUT"
