#!/usr/bin/env bash

# CONTEXT:
# This script mimics the 'aws codeartifact login' command
# This command cannot be run on the runner as the required applications will not have access to the keychain item generated

# OVERVIEW:
# This script fetches an AWS CodeArtifact authorisation token
# Fetches the URL of the ReadID AWS repository we want to access
# Uses 'swift package-registry login' to login to the repository
# Grants the required applications access to the generated keychain item

# Assign the first command-line argument to the variable Xcode_path
Xcode_path=$1

KEYCHAIN_PASSWORD=$(openssl rand -base64 20)
KEYCHAIN_NAME=dev.keychain

# Keychain set up
security create-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_NAME}"
security default-keychain -s "${KEYCHAIN_NAME}"
security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_NAME}"
security set-keychain-settings "${KEYCHAIN_NAME}"

# Add the keychain to existing keychain list
EXISTING_KEYCHAINS=( $( security list-keychains | sed -e 's/ *//' | tr '\n' ' ' | tr -d '"') )
sudo security list-keychains -s "${MATCH_KEYCHAIN_NAME}" "${EXISTING_KEYCHAINS[@]}"