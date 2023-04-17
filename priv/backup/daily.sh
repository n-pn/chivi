#!/usr/bin/env bash
set -euo pipefail

echo backup database
sudo rm -rf /mnt/serve/chivi/_pg/prod/*
sudo -u postgres pg_basebackup -D /mnt/serve/chivi/_pg/prod -p 5433

echo sync database with oracle clound
sudo chmod a=r,u+w,a+X -R /mnt/serve/chivi/_pg/prod
rclone sync /mnt/serve/chivi/_pg/prod oracle:chivi/pg_data

echo remove outdated write-ahead logs
sudo rm -rf /mnt/serve/chivi/_pg/wals/*
rclone sync /mnt/serve/chivi/_pg/wals oracle:chivi/wal_log
