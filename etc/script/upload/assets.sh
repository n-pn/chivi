#! /bin/bash

OUT=nipin@ssh.nipin.xyz:web/chivi/var/appcv

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "var/dictdb" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "var/bookdb" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "var/userdb" $OUT
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "web/public" "$OUT/web/"

# INP=var/._old_info
# OUT=nipin@ssh.chivi.xyz:web/chivi/data

# rsync -azui "$INP/cv_dicts" "$OUT"
