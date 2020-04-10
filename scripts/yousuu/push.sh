#! /bin/bash

rsync -azui --chmod=Dg+s,ug+w,Fo-w,+X data/txt-inp/yousuu/proxies nipin@ssh.nipin.xyz:web/chivi/data/txt-inp/yousuu/
rsync -azui --chmod=Dg+s,ug+w,Fo-w,+X data/txt-inp/yousuu/serials nipin@ssh.nipin.xyz:web/chivi/data/txt-inp/yousuu/
