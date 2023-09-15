#!/usr/bin/env bash

sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress --delete /2tb/bak.chivi/_db/prod/ /2tb/dev.chivi/_db/data/
sudo chmod 700 /2tb/dev.chivi/_db/data/
sudo pg_ctlcluster 14 main start
