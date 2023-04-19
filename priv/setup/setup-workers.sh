#! /bin/bash

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo cp -f "$CWD/workers/crawl-ysbooks.service" /etc/systemd/system/crawl-ysbooks.service
sudo cp -f "$CWD/workers/crawl-ysbooks.timer" /etc/systemd/system/crawl-ysbooks.timer

sudo cp -f "$CWD/workers/crawl-ysrepls.service" /etc/systemd/system/crawl-ysrepls.service
sudo cp -f "$CWD/workers/crawl-ysrepls.timer" /etc/systemd/system/crawl-ysrepls.timer

sudo cp -f "$CWD/workers/crawl-ysusers-info.service" /etc/systemd/system/crawl-ysusers-info.service
sudo cp -f "$CWD/workers/crawl-ysusers-info.timer" /etc/systemd/system/crawl-ysusers-info.timer

sudo cp -f "$CWD/workers/crawl-yscrits-by-user.service" /etc/systemd/system/crawl-yscrits-by-user.service
sudo cp -f "$CWD/workers/crawl-yscrits-by-user.timer" /etc/systemd/system/crawl-yscrits-by-user.timer

sudo cp -f "$CWD/workers/crawl-yscrits-by-list.service" /etc/systemd/system/crawl-yscrits-by-list.service
sudo cp -f "$CWD/workers/crawl-yscrits-by-list.timer" /etc/systemd/system/crawl-yscrits-by-list.timer

sudo cp -f "$CWD/workers/crawl-yscrits-by-book.service" /etc/systemd/system/crawl-yscrits-by-book.service
sudo cp -f "$CWD/workers/crawl-yscrits-by-book.timer" /etc/systemd/system/crawl-yscrits-by-book.timer


sudo systemctl daemon-reload

sudo systemctl enable crawl-ysbooks.service
sudo systemctl enable crawl-ysrepls.service
sudo systemctl enable crawl-ysusers-info.service

sudo systemctl enable crawl-yscrits-by-user.service
sudo systemctl enable crawl-yscrits-by-list.service
sudo systemctl enable crawl-yscrits-by-book.service

sudo systemctl enable --now crawl-ysbooks.timer
sudo systemctl enable --now crawl-ysrepls.timer
sudo systemctl enable --now crawl-ysusers-info.timer

sudo systemctl enable --now crawl-yscrits-by-user.timer
sudo systemctl enable --now crawl-yscrits-by-list.timer
sudo systemctl enable --now crawl-yscrits-by-book.timer
