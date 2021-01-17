#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -aiz --no-p "$SSH/_db/dictdb/legacy" "_db/dictdb"
# rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/remote/"

rsync -aiz --no-p "$SSH/_db/nvdata/viusers" "_db/nvdata"
rsync -aiz --no-p "$SSH/_db/nvdata/nvmarks" "_db/nvdata"

# rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
rsync -aiz --no-p --include="*.txt" "$SSH/_db/chdata/zhtexts" "_db/nvdata"
