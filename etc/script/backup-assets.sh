#! /bin/bash

REMOTE=deploy@ssh.chivi.xyz:www/chivi

DIR=_db/_oldcv

rsync -azi --no-p "$REMOTE/$DIR/members" $DIR
rsync -aiz --no-p "$REMOTE/_db/.cache" "_db/"
rsync -aiz --no-p "$REMOTE/_db/chtext" "_db/"
