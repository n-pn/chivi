#!/usr/bin/env bash

sudo pg_ctlcluster 16 main stop
sudo rsync -avAXEWSlHh --no-compress --delete /2tb/bak.chivi/_db/prod/ /2tb/dev.chivi/_db/pg16/
sudo chmod 700 /2tb/dev.chivi/_db/pg16/
sudo pg_ctlcluster 16 main start
