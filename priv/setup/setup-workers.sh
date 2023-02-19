#! /bin/sh

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo cp -f "$CWD/workers/crawl-ysbooks.service" /etc/systemd/system/crawl-ysbooks.service
sudo cp -f "$CWD/workers/crawl-ysbooks.timer" /etc/systemd/system/crawl-ysbooks.timer

sudo cp -f "$CWD/workers/crawl-yscrits-by-user.service" /etc/systemd/system/crawl-yscrits-by-user.service
sudo cp -f "$CWD/workers/crawl-yscrits-by-user.timer" /etc/systemd/system/crawl-yscrits-by-user.timer

sudo systemctl daemon-reload

sudo systemctl enable crawl-ysbooks.service
sudo systemctl enable crawl-yscrits-by-user.service

sudo systemctl enable --now crawl-ysbooks.timer
sudo systemctl enable --now crawl-yscrits-by-user.timer
