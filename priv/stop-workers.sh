#! /bin/bash
sudo systemctl stop ysbook_info-sync.timer
sudo systemctl stop ysbook_info-sync.service

sudo systemctl stop ysuser_info-sync.timer
sudo systemctl stop ysuser_info-sync.service

sudo systemctl stop yslist_info-sync.timer
sudo systemctl stop yslist_info-sync.service

###

sudo systemctl stop ysrepl_bycrit-sync.timer
sudo systemctl stop ysrepl_bycrit-sync.service

###

sudo systemctl stop yscrit_byuser-sync.timer
sudo systemctl stop yscrit_byuser-sync.service

sudo systemctl stop yscrit_bylist-sync.timer
sudo systemctl stop yscrit_bylist-sync.service

sudo systemctl stop yscrit_bybook-sync.timer
sudo systemctl stop yscrit_bybook-sync.service

###

sudo systemctl stop yslist_byuser-sync.timer
sudo systemctl stop yslist_byuser-sync.service

sudo systemctl stop yslist_bybook-sync.timer
sudo systemctl stop yslist_bybook-sync.service
