#! /bin/bash

rsync -azi data/dic-out/ nipin@ssh.nipin.xyz:web/chivi/data/dic-out/
rsync -azi data/txt-out/ nipin@ssh.nipin.xyz:web/chivi/data/txt-out/
rsync -azi data/txt-tmp/yousuu nipin@ssh.nipin.xyz:web/chivi/data/txt-tmp/
