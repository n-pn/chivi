#! /bin/bash

REMOTE=nipin@ssh.nipin.xyz:web/chivi

# rsync -azi --exclude '*.tab' "var/libcv/lexicon" "$REMOTE/var/libcv"

# rsync -azi "var/appcv/members" "$REMOTE/var/appcv"
rsync -azi "var/appcv/serials" "$REMOTE/var/appcv"
rsync -azi "var/appcv/indexes" "$REMOTE/var/appcv"
rsync -azi "var/appcv/chlists" "$REMOTE/var/appcv"

rsync -azi "web/public/" "$REMOTE/web/public/"
