#!/bin/bash

set -e

#make sure deps are up to date
rm -fr node_modules
yarn install

# get current version
VERSION=$(node --eval "console.log(require('./packages/node_modules/pouchdb/package.json').version);")

# Create a temporary build directory
SOURCE_DIR=$(git name-rev --name-only HEAD)

# Update dependency versions inside each package.json (replace the "*")
node bin/update-package-json-for-publish.js

# Publish all modules with Lerna
for pkg in $(ls packages/node_modules); do
  if [ ! -d "packages/node_modules/$pkg" ]; then
    continue
  elif [ "true" = $(node --eval "console.log(require('./packages/node_modules/$pkg/package.json').private);") ]; then
    continue
  fi
done

# Create git tag, which is also the Bower/Github release
rm -fr lib src dist bower.json component.json package.json
