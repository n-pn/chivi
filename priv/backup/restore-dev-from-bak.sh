#!/usr/bin/env bash

sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress --delete /2tb/app.chivi/_db/.bak/2023-08-29/ /2tb/dev.chivi/_db/data/
sudo chown postgres:postgres -R /2tb/dev.chivi/_db/data/
sudo chmod 700 -R /2tb/dev.chivi/_db/data/
sudo pg_ctlcluster 14 main start
