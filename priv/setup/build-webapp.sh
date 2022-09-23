#! /bin/sh

cd web
pnpm i
pnpm run build && sudo service chivi-web restart
