#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var/
OUT=var/

rsync -azi "$INP/dictdb" $OUT
rsync -azi "$INP/userdb" $OUT
