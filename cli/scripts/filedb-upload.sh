#! /bin/bash

SSH=nipin@ssh.chivi.xyz:srv/chivi.xyz

## upload dicts
# rsync -azi "_db/vp_dicts/active/" "$SSH/_db/vp_dicts/remote/"
# rsync -azi "_db/vp_dicts/active" "$SSH/_db/vp_dicts"

## upload user data
# rsync -azi --no-p "_db/vi_users/" "$SSH/_db/vi_users/"

## upload book data
rsync -azi --no-p --delete "_db/nv_infos/" "$SSH/_db/nv_infos/"
rsync -azi --no-p --delete "_db/ch_infos/" "$SSH/_db/ch_infos/"

# rsync -azi --no-p --delete "_db/nv_infos/covers" "$SSH/_db/nv_infos/"
