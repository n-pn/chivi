#! /bin/bash

DIR=/home/nipin/srv/chivi.app/etc/services

sudo rm /etc/systemd/system/mtlv2-srv.service
sudo cp "$DIR/mtlv2-srv.service" /etc/systemd/system/mtlv2-srv.service

sudo rm /etc/systemd/system/chivi-srv.service
sudo cp "$DIR/chivi-srv.service" /etc/systemd/system/chivi-srv.service

sudo rm /etc/systemd/system/chivi-web.service
sudo cp "$DIR/chivi-web.service" /etc/systemd/system/chivi-web.service

sudo systemctl daemon-reload

sudo systemctl enable mtlv2-srv.service
sudo service mtlv2-srv start

sudo systemctl enable chivi-srv.service
sudo service chivi-srv start

sudo systemctl enable chivi-web.service
sudo service chivi-web start

sudo cp "$DIR/chivi-web.conf" /etc/nginx/sites-available/chivi.conf
sudo ln -s /etc/nginx/sites-available/chivi.conf /etc/nginx/sites-enabled

sudo service nginx reload
