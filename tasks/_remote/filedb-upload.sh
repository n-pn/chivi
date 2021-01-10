#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

# rsync -azi "_db/cvdict/legacy" --exclude '*.log' "$SSH/_db/cvdict"
rsync -azi "_db/cvdict/active" "$SSH/_db/cvdict"
rsync -azi --exclude '*.tab' "_db/cvdict/active" "$SSH/_db/cvdict"

# rsync -azi "_db/nvdata/nvmarks" "$SSH/_db/nvdata"
# rsync -azi "_db/nvdata/viusers" "$SSH/_db/nvdata"

DIR="_db/_oldcv"

# rsync -azi --no-p "$DIR/members" "$SSH/$DIR"
rsync -azi --no-p "$DIR/serials" "$SSH/$DIR"
rsync -azi --no-p "$DIR/indexes" "$SSH/$DIR"
rsync -azi --no-p "$DIR/chlists" "$SSH/$DIR"

rsync -azi --no-p "web/public" "$SSH/web"
