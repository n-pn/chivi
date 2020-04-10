#! /bin/bash

rsync -azvW --chmod=Dg+s,ug+w,Fo-w,+X data/dic-out nipin@ssh.chivi.xyz:web/chivi/data/
rsync -azvW --chmod=Dg+s,ug+w,Fo-w,+X data/txt-out nipin@ssh.chivi.xyz:web/chivi/data/
rsync -azvW data/txt-tmp/yousuu nipin@ssh.chivi.xyz:web/chivi/data/txt-tmp/
rsync -azvW --chmod=Dg+s,ug+w,Fo-w,+X data/txt-tmp/chtexts/zhwenpg nipin@ssh.chivi.xyz:web/chivi/data/txt-tmp/chtexts/
