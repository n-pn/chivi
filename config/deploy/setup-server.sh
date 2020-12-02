#! /bin/bash

CWD=/home/deploy/www/chivi/etc/deploy/configs

sudo rm /etc/nginx/sites-enabled/chivi.conf
sudo ln -s "$CWD/chivi.nginx.conf" /etc/nginx/sites-enabled/chivi.conf

sudo cp "$CWD/chivi-client.systemd.service" /etc/systemd/system/chivi-client.service
sudo cp "$CWD/chivi-server.systemd.service" /etc/systemd/system/chivi-server.service

sudo service nginx reload
sudo systemctl daemon-reload
sudo systemctl enable chivi-server.service
sudo systemctl enable chivi-client.service
sudo service chivi-server start
sudo service chivi-client start
