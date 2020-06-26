#! /bin/sh

shards build --release chivi && sudo systemctl restart chivi-server.service
