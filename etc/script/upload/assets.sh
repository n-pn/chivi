#! /bin/bash

OUT=nipin@ssh.nipin.xyz:web/chivi

# rsync -azi "var/libcv/analyze" "$OUT/var/libcv"
rsync -azi --exclude '*.log' "var/libcv/lexicon" "$OUT/var/libcv"

# rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "var/bookdb" "$OUT/var/"
# rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "web/public" "$OUT/web/"

rsync -azi "var/appcv/members" "$OUT/var/appcv"
