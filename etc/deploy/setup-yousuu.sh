#! /bin/sh
DIR=/home/deploy/www/chivi/etc/deploy/yousuu

sudo cp "$DIR/yousuu-serials.service" /etc/systemd/system/yousuu-serials.service
sudo cp "$DIR/yousuu-serials.timer" /etc/systemd/system/yousuu-serials.timer

sudo systemctl daemon-reload
sudo systemctl enable yousuu-serials.service
sudo systemctl enable --now yousuu-serials.timer
