#! /bin/bash

# The production directory
TARGET="/home/nipin/srv/chivi.app"
# The Git repo
SOURCE="/home/nipin/git/chivi.git"

# Deploy the content
mkdir -p $TARGET
git --work-tree=$TARGET --git-dir=$SOURCE checkout -f
cd $TARGET
