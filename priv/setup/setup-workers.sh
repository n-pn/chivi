#! /bin/sh
DIR=/home/nipin/srv/chivi.xyz/etc/workers

sudo rm /etc/systemd/system/ys-serial.service
sudo cp "$DIR/ys-serial.service" /etc/systemd/system/ys-serial.service

sudo rm /etc/systemd/system/ys-serial.timer
sudo cp "$DIR/ys-serial.timer" /etc/systemd/system/ys-serial.timer

sudo rm /etc/systemd/system/ys-review.service
sudo cp "$DIR/ys-review.service" /etc/systemd/system/ys-review.service

sudo rm /etc/systemd/system/ys-review.timer
sudo cp "$DIR/ys-review.timer" /etc/systemd/system/ys-review.timer

sudo systemctl daemon-reload

sudo systemctl enable ys-serial.service
sudo systemctl enable ys-review.service

sudo systemctl enable --now ys-serial.timer
sudo systemctl enable --now ys-review.timer
