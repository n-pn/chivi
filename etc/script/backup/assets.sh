#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var
OUT=var

rsync -azi "$INP/appcv/members" "$OUT/appcv"
rsync -azi "$INP/appcv/chfiles" "$OUT/appcv"
# rsync -azi "$INP/bookdb/serials" "$OUT/bookdb"
# rsync -azi "$INP/bookdb/indexes" "$OUT/bookdb"
# rsync -azi "$INP/bookdb/chlists" "$OUT/bookdb"
