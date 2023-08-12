#!/usr/bin/env bash
set -euo pipefail

echo backup database
sudo rm -rf /2tb/dev.chivi/_pg/data/*
sudo -u postgres pg_basebackup -D /2tb/dev.chivi/_pg/data -p 5433

echo sync database with oracle cloud
sudo chmod a=r,u+w,a+X -R /2tb/dev.chivi/_pg/data
rclone sync /2tb/dev.chivi/_pg/data oracle:chivi/pg_data

echo remove outdated write-ahead logs
sudo rm -rf /2tb/dev.chivi/_pg/wals/*
rclone sync /2tb/dev.chivi/_pg/wals oracle:chivi/wal_log
