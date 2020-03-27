#! /bin/sh
ROOT=/srv/appcv

sudo cp "$ROOT/etc/services/yousuu-serials.service" /etc/systemd/system/yousuu-serials.service
sudo cp "$ROOT/etc/services/yousuu-serials.timer" /etc/systemd/system/yousuu-serials.timer

sudo systemctl daemon-reload
sudo systemctl enable yousuu-serials.service
sudo systemctl enable --now yousuu-serials.timer
