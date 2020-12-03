#! /bin/sh
DIR=/home/deploy/www/chivi/deploy/runner

sudo cp "$DIR/yousuu-infos.systemd.service" /etc/systemd/system/yousuu-infos.service
sudo cp "$DIR/yousuu-infos.systemd.timer" /etc/systemd/system/yousuu-infos.timer

sudo systemctl daemon-reload
sudo systemctl enable yousuu-infos.service
sudo systemctl enable --now yousuu-infos.timer
