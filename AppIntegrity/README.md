#  App Integrity

## Package description

This package contains the logic to implement app integrity checks using [Firebase App Check](https://firebase.google.com/docs/app-check). It therefore encorporates the Firebase SDK as a dependency, along with the Networking module to enable backend requests.

## Overview

### What is app integrity?

App Integrity describes checks made (in this case, by Firebase AppCheck) to verify that a genuine instance of your app is accessing your backend resources and that the device accessing it has not been tampered with.

### Why do we need it for mobile?

As STS supports public clients, it is susceptible to malicious attacks.

We have therefore implemented app integrity checks when the `/token` endpoint is called to ensure that the client is:
1. genuine: the client is not being impersonated
2. unmodified: the code we have deployed has not been changed by the device

This therefore adds a layer of security to our authorization flow.

## Testing

### Testing locally

Using the `AppCheckDebugProviderFactory` type when the build configuration is in Debug allows us to pass a known debug token as an environment variable to Firebase App Check.
This bypasses the app integrity checks, so that the app can be run on the simulator for development and automation testing.

This can be done by editing the scheme on xcode and passing an environment variable with the name FIRAAppCheckDebugToken.

The value should be saved in an encrypted secrets file outside of the repository or included in your .gitignore file to ensure it isn't checked into source code. It can then be passed in by including the file in your build config as shown below:

```swift
#include "../secrets.xcconfig"
```

### Automation

In order for your app to build/ run/ test successfully on the command line, the same must be done in the github workflows. This requires having the debug token saved in your CI system's secure key store (i.e GitHub Actions' encrypted secrets).

Run a command within your workflow to create a secrets file and input the debug token value.

```swift
- name: Export AppCheck Secret
env:
APP_CHECK_DEBUG_TOKEN: ${{ secrets.BUILD_APPCHECK_DEBUG_TOKEN }}
run: |
echo APP_CHECK_DEBUG_TOKEN=$APP_CHECK_DEBUG_TOKEN >> ../secrets.xcconfig

```

## Key generation & storage

Currently, this package does not facilitate the storage of keys. This part of assessing the clients integrity is done in-app with the help of the [TokenGeneration module](https://github.com/govuk-one-login/mobile-ios-networking?tab=readme-ov-file#tokengeneration)
