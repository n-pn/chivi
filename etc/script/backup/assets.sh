#! /bin/bash

INP=nipin@ssh.chivi.xyz:web/chivi/data
OUT=var/._old_info

rsync -azui "$INP/trie_dicts/*" "$OUT/trie_dicts"
# rsync -azui "$INP/zh_texts/*" "$OUT/zh_texts"
