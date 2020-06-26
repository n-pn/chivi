#! /bin/sh

yarn install && yarn build && sudo systemctl restart chivi-client.service
