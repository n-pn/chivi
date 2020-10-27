#! /bin/bash

REMOTE=deploy@ssh.chivi.xyz:web/chivi

# rsync -azi --exclude '*.tab' "var/libcv/lexicon" "$REMOTE/var/libcv"

# rsync -azi "var/appcv/members" "$REMOTE/var/appcv"
rsync -azi --no-p "var/appcv/serials" "$REMOTE/var/appcv"
rsync -azi --no-p "var/appcv/indexes" "$REMOTE/var/appcv"
rsync -azi --no-p "var/appcv/chlists" "$REMOTE/var/appcv"

rsync -azi --no-p "web/public" "$REMOTE/web"
