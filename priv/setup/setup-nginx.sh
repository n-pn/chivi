#! /bin/bash

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $CWD

OUT_FILE = /etc/nginx/sites-available/chivi-web.conf

sudo cp -f "$CWD/services/chivi-web.conf" $OUT_FILE
sudo ln -sf $OUT_FILE /etc/nginx/sites-enabled

sudo service nginx -s reload
