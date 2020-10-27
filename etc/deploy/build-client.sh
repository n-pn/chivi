#! /bin/sh

cd www && yarn install && yarn build && sudo service chivi-client restart
