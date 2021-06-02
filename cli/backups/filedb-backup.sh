#! /bin/bash

SSH=nipin@ssh.chivi.xyz:srv/chivi.xyz

rsync -aiz --no-p "$SSH/_db/vp_dicts/active/" "_db/vp_dicts/backup/"
rsync -aiz --no-p "$SSH/_db/vp_dicts/active/" "_db/vp_dicts/active/"

rsync -aiz --no-p "$SSH/_db/vi_users/" "_db/vi_users/"

rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"

rsync -aiz --no-p "$SSH/_db/ch_texts/" "_db/ch_texts/"
rsync -aiz --no-p "$SSH/_db/ch_infos/" "_db/ch_infos/"
rsync -aiz --no-p "$SSH/_db/nv_infos/" "_db/nv_infos/"
