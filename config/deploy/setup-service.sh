#! /bin/bash

DIR=/home/deploy/www/chivi/config/deploy/service

sudo cp "$DIR/chivi-server.systemd.service" /etc/systemd/system/chivi-server.service
sudo cp "$DIR/chivi-webapp.systemd.service" /etc/systemd/system/chivi-webapp.service

sudo systemctl daemon-reload

sudo systemctl enable chivi-server.service
sudo service chivi-server start

sudo systemctl enable chivi-webapp.service
sudo service chivi-webapp start

sudo cp "$DIR/chivi-webapp.nginx.conf" /etc/nginx/sites-available/chivi.conf
sudo ln -s /etc/nginx/sites-available/chivi.conf /etc/nginx/sites-enabled

sudo service nginx reload
