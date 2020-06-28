#! /bin/sh

cd www && yarn install && yarn build && sudo systemctl restart chivi-client.service
