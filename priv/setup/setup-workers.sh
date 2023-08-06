#! /bin/bash

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo cp -f "$CWD/workers/backup-hourly.service" /etc/systemd/system/backup-hourly.service
sudo cp -f "$CWD/workers/backup-hourly.timer" /etc/systemd/system/backup-hourly.timer

sudo cp -f "$CWD/workers/backup-daily.service" /etc/systemd/system/backup-daily.service
sudo cp -f "$CWD/workers/backup-daily.timer" /etc/systemd/system/backup-daily.timer

sudo cp -f "$CWD/workers/ysbook_info-sync.service" /etc/systemd/system/ysbook_info-sync.service
sudo cp -f "$CWD/workers/ysbook_info-sync.timer" /etc/systemd/system/ysbook_info-sync.timer

sudo cp -f "$CWD/workers/ysrepl_bycrit-sync.service" /etc/systemd/system/ysrepl_bycrit-sync.service
sudo cp -f "$CWD/workers/ysrepl_bycrit-sync.timer" /etc/systemd/system/ysrepl_bycrit-sync.timer

sudo cp -f "$CWD/workers/ysuser_info-sync.service" /etc/systemd/system/ysuser_info-sync.service
sudo cp -f "$CWD/workers/ysuser_info-sync.timer" /etc/systemd/system/ysuser_info-sync.timer

sudo cp -f "$CWD/workers/yscrit_byuser-user.service" /etc/systemd/system/yscrit_byuser-user.service
sudo cp -f "$CWD/workers/yscrit_byuser-user.timer" /etc/systemd/system/yscrit_byuser-user.timer

sudo cp -f "$CWD/workers/yscrit_bylist-sync.service" /etc/systemd/system/yscrit_bylist-sync.service
sudo cp -f "$CWD/workers/yscrit_bylist-sync.timer" /etc/systemd/system/yscrit_bylist-sync.timer

sudo cp -f "$CWD/workers/yscrit_bybook-sync.service" /etc/systemd/system/yscrit_bybook-sync.service
sudo cp -f "$CWD/workers/yscrit_bybook-sync.timer" /etc/systemd/system/yscrit_bybook-sync.timer

sudo systemctl daemon-reload

sudo systemctl enable backup-hourly.service
sudo systemctl enable --now backup-hourly.timer

sudo systemctl enable backup-daily.service
sudo systemctl enable --now backup-daily.timer

###

sudo systemctl enable ysbook_info-sync.service
sudo systemctl enable --now ysbook_info-sync.timer

sudo systemctl enable ysuser_info-sync.service
sudo systemctl enable --now ysuser_info-sync.timer

sudo systemctl enable yslist_info-sync.service
sudo systemctl enable --now yslist_info-sync.timer

###

sudo systemctl enable yslist_bybook-sync.service
sudo systemctl enable --now yslist_bybook-sync.timer

sudo systemctl enable yslist_byuser-sync.service
sudo systemctl enable --now yslist_byuser-sync.timer

######


sudo systemctl enable ysrepl_bycrit-sync.service
sudo systemctl enable --now ysrepl_bycrit-sync.timer

sudo systemctl enable yscrit_byuser-sync.service
sudo systemctl enable --now yscrit_byuser-sync.timer

sudo systemctl enable yscrit_bylist-sync.service
sudo systemctl enable --now yscrit_bylist-sync.timer

sudo systemctl enable yscrit_bybook-sync.service
sudo systemctl enable --now yscrit_bybook-sync.timer
