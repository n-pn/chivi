#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var
OUT=var

rsync -azi "$INP/appcv/members" "$OUT/appcv"
# rsync -aiz "$INP/appcv/serials/indexes" "$OUT/appcv/serials"
rsync --ignore-existing -aiz "$INP/appcv/chtexts" "$OUT/appcv"
# rsync -az "$INP/bookdb/serials" "$OUT/bookdb"
# rsync -az "$INP/bookdb/chlists" "$OUT/bookdb"
