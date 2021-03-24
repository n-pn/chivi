#! /bin/bash

SSH=nipin@dev.chivi.xyz:www/chivi.xyz

rsync -aiz --no-p "$SSH/_db/userdb/viusers" "_db/userdb"
rsync -aiz --no-p "$SSH/_db/marked/" "_db/marked/"

rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/remote/"
rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/active/"

# rsync -aiz --no-p "$SSH/_db/chdata/zhinfos" "_db/chdata"
# rsync -aiz --no-p "$SSH/_db/chdata/chheads" "_db/chdata"
rsync -aiz --no-p "$SSH/_db/chdata/zhtexts" "_db/chdata"

rsync -aiz --no-p --exclude "shubaow" --exclude "69shu" "$SSH/_db/.cache/" "_db/.cache/"
