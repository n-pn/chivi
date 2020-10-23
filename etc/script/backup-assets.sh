#! /bin/bash

REMOTE=nipin@ssh.nipin.xyz:web/chivi

rsync -azi --no-p "$REMOTE/var/appcv/members" "var/appcv"
rsync -aiz --no-p --ignore-existing "$REMOTE/_db/prime/chdata/texts" "_db/prime/chdata"
# rsync -az "$REMOTE/var/appcv/chlists/" "var/appcv/chlists/"
# rsync -az "$REMOTE/var/appcv/serials/" "var/appcv/serials/"
