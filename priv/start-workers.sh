#! /bin/bash
sudo systemctl start --now ysbook_info-sync.timer
sudo systemctl start --now ysuser_info-sync.timer
sudo systemctl start --now yslist_info-sync.timer

sudo systemctl start --now ysrepl_bycrit-sync.timer

sudo systemctl start --now yscrit_byuser-sync.timer
sudo systemctl start --now yscrit_bylist-sync.timer
sudo systemctl start --now yscrit_bybook-sync.timer

sudo systemctl start --now yslist_byuser-sync.timer
sudo systemctl start --now yslist_bybook-sync.timer
