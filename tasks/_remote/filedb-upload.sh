#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

# rsync -azi "_db/cvdict/legacy" --exclude '*.log' "$SSH/_db/cvdict"
rsync -azi "_db/cvdict/active" "$SSH/_db/cvdict"
# rsync -azi --exclude '*.tab' "_db/cvdict/active" "$SSH/_db/cvdict"

# rsync -azi "_db/nvdata/nvmarks" "$SSH/_db/nvdata"
# rsync -azi "_db/nvdata/viusers" "$SSH/_db/nvdata"

DIR="_db/nvdata"

# rsync -azi --no-p "$DIR/viusers" "$SSH/$DIR"
rsync -azi --no-p "$DIR/nvinfos" "$SSH/$DIR"
rsync -azi --no-p "$DIR/chseeds" "$SSH/$DIR"
rsync -azi --no-p "$DIR/chinfos" "$SSH/$DIR"

rsync -azi --no-p "$DIR/_covers/" "$SSH/web/public/covers/"
