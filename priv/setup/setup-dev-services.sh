#! /bin/bash
set -e pipefail

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $CWD

sudo cp -f "$CWD/services/cvapp-dev.service" /etc/systemd/system/cvapp-dev.service
sudo cp -f "$CWD/services/cvweb-dev.service" /etc/systemd/system/cvweb-dev.service
sudo cp -f "$CWD/services/mt_v1-dev.service" /etc/systemd/system/mt_v1-dev.service
sudo cp -f "$CWD/services/mt_v2-dev.service" /etc/systemd/system/mt_v2-dev.service
sudo cp -f "$CWD/services/mt_sp-dev.service" /etc/systemd/system/mt_sp-dev.service
sudo cp -f "$CWD/services/ysapp-dev.service" /etc/systemd/system/ysapp-dev.service
sudo cp -f "$CWD/services/wnapp-dev.service" /etc/systemd/system/wnapp-dev.service
#sudo cp -f "$CWD/services/hanlp-dev.service" /etc/systemd/system/hanlp-dev.service

sudo systemctl daemon-reload

sudo systemctl enable cvapp-dev.service
sudo service cvapp-dev restart

sudo systemctl enable cvweb-dev.service
sudo service cvweb-dev restart

sudo systemctl enable ysapp-dev.service
sudo service ysapp-dev restart

sudo systemctl enable mt_sp-dev.service
sudo service mt_sp-dev restart

sudo systemctl enable mt_v1-dev.service
sudo service mt_v1-dev restart

sudo systemctl enable mt_v2-dev.service
sudo service mt_v2-dev restart

sudo systemctl enable wnapp-dev.service
sudo service wnapp-dev restart

#sudo systemctl enable hanlp-dev.service
#sudo service hanlp-dev restart
