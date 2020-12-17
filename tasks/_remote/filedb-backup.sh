#! /bin/bash

SSH=deploy@dev.chivi.xyz:www/chivi

rsync -azi --no-p "$SSH/_db/_oldcv/members" "_db/_oldcv"

rsync -aiz --no-p "$SSH/_db/cvdict/legacy" "_db/cvdict"
# rsync -aiz --no-p "$SSH/_db/cvdict/active/" "_db/cvdict/remote/"

rsync -aiz --no-p "$SSH/_db/.cache/" "_db/.cache/"
rsync -aiz --no-p --include="*.txt" "$SSH/_db/zhtext/_chivi" "_db/zhtext/"
