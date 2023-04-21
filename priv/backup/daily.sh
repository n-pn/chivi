#!/usr/bin/env bash
set -euo pipefail

echo backup database
sudo rm -rf /www/chivi/app/_pg/data/*
sudo -u postgres pg_basebackup -D /www/chivi/app/_pg/data -p 5433

echo sync database with oracle cloud
sudo chmod a=r,u+w,a+X -R /www/chivi/app/_pg/data
rclone sync /www/chivi/app/_pg/data oracle:chivi/pg_data

echo remove outdated write-ahead logs
sudo rm -rf /www/chivi/app/_pg/wals/*
rclone sync /www/chivi/app/_pg/wals oracle:chivi/wal_log
