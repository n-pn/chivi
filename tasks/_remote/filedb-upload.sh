#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -azi "_db/dictdb/active/" "$SSH/_db/dictdb/remote/"
# rsync -azi "_db/dictdb/active" "$SSH/_db/dictdb"
# rsync -azi --exclude '*.tab' "_db/dictdb/active" "$SSH/_db/dictdb"

## upload book data
# rsync -azi --no-p "_db/nvdata/nvinfos" "$SSH/_db/nvdata"
rsync -azi --no-p "_db/nvdata/chseeds" "$SSH/_db/nvdata"

## upload chap data
# rsync -azi --no-p "_db/chdata/chorigs" "$SSH/_db/chdata"
# rsync -azi --no-p "_db/chdata/chheads" "$SSH/_db/chdata"
# rsync -azi --no-p "_db/chdata/chinfos" "$SSH/_db/chdata"
# rsync -azi --no-p "_db/chdata/chstats" "$SSH/_db/chdata"

## upload book covers
# rsync -azi --no-p "_db/bcover/" "$SSH/_db/bcover/"

## upload user data
# rsync -azi --no-p "_db/userdb/viusers" "$SSH/_db/userdb"
# rsync -azi "_db/marked/" "$SSH/_db/marked/"
