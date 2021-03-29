#! /bin/sh
DIR=/home/nipin/srv/chivi.xyz/config/workers

sudo cp "$DIR/ys-serial.service" /etc/systemd/system/ys-serial.service
sudo cp "$DIR/ys-serial.timer" /etc/systemd/system/ys-serial.timer

sudo systemctl daemon-reload
sudo systemctl enable ys-serial.service
sudo systemctl enable --now ys-serial.timer
