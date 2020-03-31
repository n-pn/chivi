#! /bin/bash

rsync -azi tasks/yousuu/ nipin@ssh.nipin.xyz:srv/yousuu/
rsync -azi data/txt-inp/yousuu/ nipin@ssh.nipin.xyz:srv/yousuu/.inp/
