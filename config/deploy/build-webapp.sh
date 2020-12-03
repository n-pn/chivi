#! /bin/sh

cd www && yarn && yarn build && sudo service chivi-webapp restart
