#! /bin/bash

rsync -azi data/dic-out/ nipin@ssh.chivi.xyz:web/chivi/data/dic-out/
rsync -azi data/txt-out/ nipin@ssh.chivi.xyz:web/chivi/data/txt-out/
rsync -azi data/txt-tmp/yousuu nipin@ssh.chivi.xyz:web/chivi/data/txt-tmp/
rsync -azi data/txt-tmp/chtexts/zhwenpg nipin@ssh.chivi.xyz:web/chivi/data/txt-tmp/chtexts/
