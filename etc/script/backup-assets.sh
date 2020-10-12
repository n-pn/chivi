#! /bin/bash

REMOTE=nipin@ssh.nipin.xyz:web/chivi

rsync -azi "$REMOTE/var/appcv/members/" "var/appcv/members/"
rsync -aiz --ignore-existing "$REMOTE/_db/prime/chtexts/" "_db/prime/chtexts/"
# rsync -az "$REMOTE/var/appcv/chlists/" "var/appcv/chlists/"
# rsync -az "$REMOTE/var/appcv/serials/" "var/appcv/serials/"
