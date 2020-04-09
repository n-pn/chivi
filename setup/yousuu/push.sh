#! /bin/bash

rsync -azi init/yousuu/ nipin@ssh.nipin.xyz:srv/yousuu/
rsync -azi data/txt-inp/yousuu/serials/ nipin@ssh.nipin.xyz:srv/yousuu/.inp/serials/
rsync -azi data/txt-inp/yousuu/proxies/ nipin@ssh.nipin.xyz:srv/yousuu/.inp/proxies/
