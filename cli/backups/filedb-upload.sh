#! /bin/bash

SSH=nipin@ssh.chivi.xyz:srv/chivi.xyz

## upload dicts
rsync -azi --no-p "_db/vp_dicts/_inits/" "$SSH/_db/vp_dicts/_inits/"
rsync -azi --no-p "_db/vp_dicts/active/" "$SSH/_db/vp_dicts/backup/"
# rsync -azi --no-p "_db/vp_dicts/active/" "$SSH/_db/vp_dicts/active/"

## upload user data
# rsync -azi --no-p "_db/vi_users/" "$SSH/_db/vi_users/"

## upload parsed seed data
rsync -azi --no-p "_db/_seeds/" "$SSH/_db/_seeds/"

## upload book data
# rsync -azi --no-p "_db/nv_infos/" "$SSH/_db/nv_infos/"
# rsync -azi --no-p "_db/ch_infos/" "$SSH/_db/ch_infos/"

rsync -azi --no-p --delete "_db/nv_infos/covers" "$SSH/_db/nv_infos/"
