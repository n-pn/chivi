#! /bin/bash

DIR=/home/nipin/srv/chivi.app/setup/services

sudo rm /etc/systemd/system/cvmtl-srv.service
sudo cp "$DIR/cvmtl-srv.service" /etc/systemd/system/cvmtl-srv.service

sudo rm /etc/systemd/system/chivi-srv.service
sudo cp "$DIR/chivi-srv.service" /etc/systemd/system/chivi-srv.service

sudo rm /etc/systemd/system/chivi-web.service
sudo cp "$DIR/chivi-web.service" /etc/systemd/system/chivi-web.service

sudo systemctl daemon-reload

sudo systemctl enable cvmtl-srv.service
sudo service cvmtl-srv start

sudo systemctl enable chivi-srv.service
sudo service chivi-srv start

sudo systemctl enable chivi-web.service
sudo service chivi-web start

sudo cp "$DIR/chivi-web.conf" /etc/nginx/sites-available/chivi-web.conf
sudo ln -s /etc/nginx/sites-available/chivi-web.conf /etc/nginx/sites-enabled

sudo service nginx reload
