#! /bin/bash

# The production directory
TARGET="/home/deploy/www/chivi.xyz"
# The Git repo
SOURCE="/home/deploy/git/chivi.git"

# Deploy the content
mkdir -p $TARGET
git --work-tree=$TARGET --git-dir=$SOURCE checkout -f
cd $TARGET

shards build --release chivi && sudo service chivi-srv restart
cd web && yarn install && yarn build && sudo service chivi-web restart
