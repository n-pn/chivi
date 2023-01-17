#! /bin/bash

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $CWD

sudo service cvhlp-srv stop
sudo systemctl disable cvhlp-srv.service
rm -f /etc/systemd/system/cvhlp-srv.service
rm -f /etc/systemd/system/cvhlp-srv.conf

sudo service cvmtl-mon stop

sudo systemctl disable cvmtl-mon.path
rm -f /etc/systemd/system/cvmtl-mon.path
rm -f /etc/systemd/system/cvmtl-mon.conf

sudo systemctl disable cvmtl-mon.service
rm -f /etc/systemd/system/cvmtl-mon.service
rm -f /etc/systemd/system/cvmtl-mon.conf

sudo service cvmtl-srv stop

sudo systemctl disable cvmtl-srv.service
rm -f /etc/systemd/system/cvmtl-srv.service
rm -f /etc/systemd/system/cvmtl-srv.conf
