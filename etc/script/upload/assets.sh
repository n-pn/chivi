#! /bin/bash

OUT=nipin@ssh.nipin.xyz:web/chivi

rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "var/dictdb" "$OUT/var/"
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "var/bookdb" "$OUT/var/"
# rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "var/userdb" "$OUT/var/"
rsync -azi --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r "web/public" "$OUT/web/"

# INP=var/._old_info
# OUT=nipin@ssh.chivi.xyz:web/chivi/data

# rsync -azui "$INP/trie_dicts" "$OUT"
