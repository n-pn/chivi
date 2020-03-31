ROOT=/home/nipin/web/chivi/setup/services

sudo rm /etc/nginx/sites-enabled/chivi.conf
sudo ln -s "$ROOT/chivi-nginx.conf" /etc/nginx/sites-enabled/chivi.conf

sudo cp "$ROOT/chivi-server.service" /etc/systemd/system/chivi-server.service
sudo cp "$ROOT/chivi-client.service" /etc/systemd/system/chivi-client.service

sudo service nginx reload
sudo systemctl daemon-reload
sudo systemctl enable chivi-server.service
sudo systemctl enable chivi-client.service
sudo service chivi-server start
sudo service chivi-client start
