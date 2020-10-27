#! /bin/sh

shards build --release chivi && sudo service chivi-server restart
