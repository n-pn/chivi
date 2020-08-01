#! /bin/bash

OUT=nipin@ssh.nipin.xyz:web/chivi

rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r --exclude '*.log' "var/dictdb" "$OUT/var/"
rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "var/bookdb" "$OUT/var/"
rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "web/public" "$OUT/web/"

# rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "var/userdb" "$OUT/var/"
