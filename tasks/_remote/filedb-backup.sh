#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/remote/"
rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb"

rsync -aiz --no-p "$SSH/_db/nvdata/nvinfos/_atime.tsv" "_db/nvdata/nvinfos"

rsync -aiz --no-p "$SSH/_db/userdb/viusers" "_db/userdb"
rsync -aiz --no-p "$SSH/_db/marked/" "_db/marked/"

rsync -aiz --no-p --exclude "*.json" "$SSH/_db/.cache/" "_db/.cache/"
rsync -aiz --no-p --exclude "*.zip" "$SSH/_db/chdata/zhtexts" "_db/chdata"
