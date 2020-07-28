#! /bin/bash

OUT=nipin@ssh.nipin.xyz:web/chivi

rsync -azui --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r --exclude '*.log' "var/dictdb" "$OUT/var/"
rsync -azui --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "var/bookdb" "$OUT/var/"
# rsync -azi --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "var/userdb" "$OUT/var/"
rsync -azui --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r "web/public" "$OUT/web/"

# INP=var/._old_info
# OUT=nipin@ssh.chivi.xyz:web/chivi/data

# rsync -azui "$INP/base_dicts" "$OUT"
