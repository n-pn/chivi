#! /bin/bash

shopt -s globstar
for f in _db/_seeds/*/covers/*.jpg; do
    type=$(file -0 -F" " "$f" | grep -aPo '\0\s*\K\S+')
    mv "$f" "${f%%.*}.${type,,}"
done
