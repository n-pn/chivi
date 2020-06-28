#! /bin/bash

CWD=/home/nipin/web/chivi/deploy/configs

sudo rm /etc/nginx/sites-enabled/chivi.conf
sudo ln -s "$CWD/nginx.conf" /etc/nginx/sites-enabled/chivi.conf

sudo cp "$CWD/chivi-client.service" /etc/systemd/system/chivi-client.service
sudo cp "$CWD/chivi-oldsrv.service" /etc/systemd/system/chivi-server.service

sudo service nginx reload
sudo systemctl daemon-reload
sudo systemctl enable chivi-server.service
sudo systemctl enable chivi-client.service
sudo service chivi-server start
sudo service chivi-client start
