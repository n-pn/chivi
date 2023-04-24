#! /bin/bash
set -euo pipefail

CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo current directory: $CWD

TGT=/etc/nginx/sites-available/chivi-web.conf

sudo cp -f "$CWD/services/chivi-web.conf" $TGT
sudo ln -sf $TGT /etc/nginx/sites-enabled

sudo service nginx -s reload
