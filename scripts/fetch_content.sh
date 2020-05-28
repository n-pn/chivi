#! /bin/bash

INP=nipin@ssh.chivi.xyz:web/chivi/data
OUT=data

rsync -azui "$INP/cv_dicts" "$OUT/"
