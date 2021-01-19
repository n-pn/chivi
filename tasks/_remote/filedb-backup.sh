#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -aiz --no-p "$SSH/_db/cvdict/legacy" "_db/dictdb"
# rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/remote/"

rsync -aiz --no-p "$SSH/_db/nvdata/viusers/" "_db/userdb/viusers/"
rsync -aiz --no-p "$SSH/_db/nvdata/nvmarks/" "_db/marked/"

# rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
# rsync -aiz --no-p --include="*.txt" "$SSH/_db/nvdata/zhtexts" "_db/chdata"
