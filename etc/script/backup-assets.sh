#! /bin/bash

REMOTE=deploy@ssh.chivi.xyz:www/chivi

rsync -azi --no-p "$REMOTE/var/appcv/members" "var/appcv"
rsync -aiz --no-p --ignore-existing "$REMOTE/_db/prime/chdata" "_db/prime"
# rsync -az "$REMOTE/var/appcv/chlists/" "var/appcv/chlists/"
# rsync -az "$REMOTE/var/appcv/serials/" "var/appcv/serials/"
