#! /bin/sh

shards install && shards build --release chivi && sudo service chivi-server restart
