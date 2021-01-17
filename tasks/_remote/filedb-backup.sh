#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -aiz --no-p "$SSH/_db/cvdict/legacy" "_db/cvdict"
# rsync -aiz --no-p "$SSH/_db/cvdict/active/" "_db/cvdict/remote/"

rsync -aiz --no-p "$SSH/_db/nvdata/viusers" "_db/nvdata"
rsync -aiz --no-p "$SSH/_db/nvdata/nvmarks" "_db/nvdata"

# rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
rsync -aiz --no-p --include="*.txt" "$SSH/_db/nvdata/zhtexts" "_db/nvdata"
