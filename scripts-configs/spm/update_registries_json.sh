#!/usr/bin/env bash

# CONTEXT:
# Since the mobile-id-check-ios repoistory is not a package the setupKeychain.sh script cannot generate two registries.json files.

# This script creates the home directory registries.json file

mkdir -p .swiftpm/configuration

echo '{
"authentication" : {
  "readid-101014119721.d.codeartifact.eu-west-1.amazonaws.com" : {
    "loginAPIPath" : "/swift/ios-ui-saas/login",
    "type" : "token"
  }
},
"registries" : {
  "[default]" : {
    "supportsAvailability" : false,
    "url" : "https://readid-101014119721.d.codeartifact.eu-west-1.amazonaws.com/swift/ios-ui-saas/"
  }
},
"version" : 1
}' >> .swiftpm/configuration/registries.json