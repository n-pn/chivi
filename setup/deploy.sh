#! /bin/bash

shards build --release server && sudo systemctl restart chivi-server.service
cd web && yarn && yarn build && sudo systemctl restart chivi-client.service
