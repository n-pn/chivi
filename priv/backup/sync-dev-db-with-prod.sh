#!/usr/bin/env bash

#DIR=/2tb/bak.chivi/_db/prod/
DIR=/2tb/app.chivi/_db/.bak/2024-02-22
sudo pg_ctlcluster 16 main stop
sudo rsync -avAXEWSlHh --no-compress --delete $DIR /2tb/dev.chivi/_db/pg16/
sudo chmod 700 /2tb/dev.chivi/_db/pg16/
sudo pg_ctlcluster 16 main start
