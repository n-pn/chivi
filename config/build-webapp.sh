#! /bin/sh

cd web && yarn && yarn build && sudo service chivi-web restart
