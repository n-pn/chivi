#! /bin/bash

OUT=nipin@ssh.nipin.xyz:web/chivi

# rsync -azi "var/libcv/analyze" "$OUT/var/libcv"
# rsync -azi --exclude '*.log' "var/libcv/lexicon" "$OUT/var/libcv"

# rsync -azi "var/appcv/members" "$OUT/var/appcv"
# rsync -azi "var/appcv/serials" "$OUT/var/appcv"
# rsync -azi "var/appcv/indexes" "$OUT/var/appcv"
# rsync -azi "var/appcv/chlists" "$OUT/var/appcv"
rsync -azi "var/appcv/chtexts" "$OUT/var/appcv"

# rsync -azi "web/public" "$OUT/web/"
