#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var/
OUT=var/

rsync -azi "$INP/dictdb" "$OUT/libcv/.backup"
rsync -azi "$INP/userdb" $OUT
# rsync -azi "$INP/bookdb/serials" "$OUT/bookdb"
# rsync -azi "$INP/bookdb/indexes" "$OUT/bookdb"
# rsync -azi "$INP/bookdb/chlists" "$OUT/bookdb"
# rsync -azi "$INP/bookdb/chfiles" "$OUT/bookdb"
