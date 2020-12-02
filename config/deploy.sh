#! /bin/sh

shards build --release server && sudo systemctl restart chivi-server.service
cd web && yarn install && yarn build && sudo systemctl restart chivi-client.service
