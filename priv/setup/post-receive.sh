#! /bin/bash

# The production directory
TARGET="/app/chivi/srv"
# The Git repo
SOURCE="/app/chivi/git"

# Deploy the content
mkdir -p $TARGET
git --work-tree=$TARGET --git-dir=$SOURCE checkout -f

# cd $TARGET
