#! /bin/bash

DIR=/home/deploy/www/chivi/config/services

sudo cp "$DIR/chivi-srv.service" /etc/systemd/system/chivi-srv.service
sudo cp "$DIR/chivi-web.service" /etc/systemd/system/chivi-web.service

sudo systemctl daemon-reload

sudo systemctl enable chivi-srv.service
sudo service chivi-srv start

sudo systemctl enable chivi-web.service
sudo service chivi-web start

sudo cp "$DIR/chivi-web.conf" /etc/nginx/sites-available/chivi.conf
sudo ln -s /etc/nginx/sites-available/chivi.conf /etc/nginx/sites-enabled

sudo service nginx reload
