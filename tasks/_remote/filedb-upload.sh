#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

# rsync -azi "_db/dictdb/legacy" --exclude '*.log' "$SSH/_db/dictdb"
rsync -azi "_db/dictdb/active" "$SSH/_db/dictdb"
# rsync -azi --exclude '*.tab' "_db/dictdb/active" "$SSH/_db/dictdb"

## upload book data
rsync -azi --no-p "_db/nvdata/nvinfos" "$SSH/_db/nvdata"
rsync -azi --no-p "_db/nvdata/chseeds" "$SSH/_db/nvdata"

## upload book covers
rsync -azi --no-p "_db/bcover/" "$SSH/web/public/covers/"

## upload chap data
rsync -azi --no-p "_db/chdata/chinfos" "$SSH/_db/chdata"

## upload user data
# rsync -azi --no-p "_db/userdb/viusers" "$SSH/_db/userdb"
# rsync -azi "_db/marked" "$SSH/_db"
