#! /bin/sh

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo cp -f "$CWD/workers/ys-serial.service" /etc/systemd/system/ys-serial.service
sudo cp -f "$CWD/workers/ys-serial.timer" /etc/systemd/system/ys-serial.timer

sudo cp -f "$CWD/workers/ys-review.service" /etc/systemd/system/ys-review.service
sudo cp -f "$CWD/workers/ys-review.timer" /etc/systemd/system/ys-review.timer

sudo systemctl daemon-reload

sudo systemctl enable ys-serial.service
sudo systemctl enable ys-review.service

sudo systemctl enable --now ys-serial.timer
sudo systemctl enable --now ys-review.timer
