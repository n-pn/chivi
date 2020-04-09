#! /bin/sh
ROOT=/home/nipin/web/chivi/services/yousuu

sudo cp "$ROOT/services/yousuu-serials.service" /etc/systemd/system/yousuu-serials.service
sudo cp "$ROOT/services/yousuu-serials.timer" /etc/systemd/system/yousuu-serials.timer

sudo systemctl daemon-reload
sudo systemctl enable yousuu-serials.service
sudo systemctl enable --now yousuu-serials.timer
