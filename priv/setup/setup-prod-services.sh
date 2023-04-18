#! /bin/bash
set -e pipefail

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $CWD

sudo cp -f "$CWD/services/cvapp-srv.service" /etc/systemd/system/cvapp-srv.service
sudo cp -f "$CWD/services/cvweb-srv.service" /etc/systemd/system/cvweb-srv.service
sudo cp -f "$CWD/services/mt_v1-srv.service" /etc/systemd/system/mt_v1-srv.service
sudo cp -f "$CWD/services/mt_v2-srv.service" /etc/systemd/system/mt_v2-srv.service
sudo cp -f "$CWD/services/mt_sp-srv.service" /etc/systemd/system/mt_sp-srv.service
sudo cp -f "$CWD/services/ysapp-srv.service" /etc/systemd/system/ysapp-srv.service
sudo cp -f "$CWD/services/wnapp-srv.service" /etc/systemd/system/wnapp-srv.service
#sudo cp -f "$CWD/services/hanlp-srv.service" /etc/systemd/system/hanlp-srv.service

sudo systemctl daemon-reload

sudo systemctl enable cvapp-srv.service
sudo service cvapp-srv restart

sudo systemctl enable wnapp-srv.service
sudo service wnapp-srv restart

sudo systemctl enable ysapp-srv.service
sudo service ysapp-srv restart

#sudo systemctl enable hanlp-srv.service
#sudo service hanlp-srv restart

sudo systemctl enable mt_sp-srv.service
sudo service mt_sp-srv restart

sudo systemctl enable mt_v1-srv.service
sudo service mt_v1-srv restart

sudo systemctl enable mt_v2-srv.service
sudo service mt_v2-srv restart

sudo systemctl enable cvweb-srv.service
sudo service cvweb-srv restart
