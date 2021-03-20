#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -aiz --no-p "$SSH/_db/userdb/viusers" "_db/userdb"
rsync -aiz --no-p "$SSH/_db/marked/" "_db/marked/"

rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/remote/"
rsync -aiz --no-p "$SSH/_db/dictdb/active/" "_db/dictdb/active/"

rsync -aiz --no-p "$SSH/_db/nvdata/nvinfos/_atime.tsv" "_db/nvdata/nvinfos"
rsync -aiz --no-p "$SSH/_db/nvdata/nvinfos/_utime.tsv" "_db/nvdata/nvinfos"
rsync -aiz --no-p "$SSH/_db/nvdata/chseeds" "_db/nvdata"

# rsync -aiz --no-p "$SSH/_db/chdata/zhinfos" "_db/chdata"
# rsync -aiz --no-p "$SSH/_db/chdata/chheads" "_db/chdata"
rsync -aiz --no-p "$SSH/_db/chdata/zhtexts" "_db/chdata"

rsync -aiz --no-p --exclude "shubaow" --exclude "69shu" "$SSH/_db/.cache/" "_db/.cache/"
