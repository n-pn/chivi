#! /bin/bash
set -e pipefail

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $CWD

sudo cp -f "$CWD/services/cvapp-srv.service" /etc/systemd/system/cvapp-srv.service
sudo cp -f "$CWD/services/cvweb-srv.service" /etc/systemd/system/cvweb-srv.service
sudo cp -f "$CWD/services/cvmtl-srv.service" /etc/systemd/system/cvmtl-srv.service
sudo cp -f "$CWD/services/cvhlp-srv.service" /etc/systemd/system/cvhlp-srv.service
sudo cp -f "$CWD/services/ysapp-srv.service" /etc/systemd/system/ysapp-srv.service

sudo systemctl daemon-reload

sudo systemctl enable cvapp-srv.service
sudo service cvapp-srv restart

sudo systemctl enable cvweb-srv.service
sudo service cvweb-srv restart

sudo systemctl enable cvhlp-srv.service
sudo service cvhlp-srv restart

sudo systemctl enable ysapp-srv.service
sudo service ysapp-srv restart
