#! /bin/bash

SSH=nipin@ssh.chivi.xyz:srv/chivi.xyz

rsync -aiz --no-p "$SSH/_db/vi_users/" "_db/vi_users/" &

rsync -aiz --no-p "$SSH/_db/vpdict/logs/" "_db/vpdict/logs/"
rsync -aiz --no-p "$SSH/_db/vpdict/main/" "_db/vpdict/main/" &
rsync -aiz --no-p "$SSH/_db/vpdict/pleb/" "_db/vpdict/pleb/" &
rsync -aiz --no-p "$SSH/_db/vpdict/main" "_db/vpdict/.bak/" &
rsync -aiz --no-p "$SSH/_db/vpdict/pleb" "_db/vpdict/.bak/" &
rsync -aiz --no-p "$SSH/_db/vpdict/logs" "_db/vpdict/.bak/" &

rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
rsync -aiz --no-p "$SSH/_db/chseed/" "_db/chseed/"
rsync -aiz --no-p "$SSH/_db/zhbook/" "_db/zhbook/"
# rsync -aiz --no-p "$SSH/_db/chtran/" "_db/chtran/"

rsync -aiz --no-p "$SSH/_db/nv_infos/chseeds" "_db/nv_infos/"
rsync -aiz --no-p "$SSH/_db/nv_infos/update.tsv" "_db/nv_infos/"
rsync -aiz --no-p "$SSH/_db/nv_infos/access.tsv" "_db/nv_infos/"
# rsync -aiz --no-p "$SSH/_db/nv_infos/rating.tsv" "_db/nv_infos/"
