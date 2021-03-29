#! /bin/bash

SSH=nipin@ssh.chivi.xyz:www/chivi.xyz

rsync -azi "_db/dictdb/active/" "$SSH/_db/dictdb/remote/"
rsync -azi "_db/dictdb/active" "$SSH/_db/dictdb"

## upload book data
rsync -azi --no-p "_db/nv_infos/" "$SSH/_db/nv_infos/"
rsync -azi --no-p "_db/ch_infos/" "$SSH/_db/ch_infos/"

## upload user data
rsync -azi --no-p "_db/vi_users/" "$SSH/_db/vi_users/"
rsync -azi "_db/marked/" "$SSH/_db/marked/"
