#! /bin/bash

INP=data/_init/books/yousuu
OUT=nipin@ssh.nipin.xyz:web/chivi/data/txt-inp/yousuu

rsync -azui --chmod=Dg+s,ug+w,Fo-w,+X "$INP/proxies/awmproxy.com.txt" "$OUT/proxies"
rsync -azui --chmod=Dg+s,ug+w,Fo-w,+X "$INP/proxies/openproxy.space.txt" "$OUT/proxies"
rsync -azui --chmod=Dg+s,ug+w,Fo-w,+X "$INP/proxies/proxyscrape.com.txt" "$OUT/proxies"

rsync -azui --chmod=Dg+s,ug+w,Fo-w,+X "$INP/serials" "$OUT/serials"
