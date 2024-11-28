#  App Integrity

## Package description

This package contains the logic to implement app integrity checks using [Firebase App Check](https://firebase.google.com/docs/app-check). It therefore encorporates the Firebase SDK as a dependency, along with the Networking module to enable backend requests.

## Testing

### Testing locally

Using the AppCheckDebugProviderFactory type when the build configuration is in Debug  allows us to pass a known debug token as an environment variable to Firebase App Check.

This can be done by editing the scheme on xcode and passing an environment variable with the name FIRAAppCheckDebugToken.

The value should be saved in an encrypted secrets file outside of the repository and passed in by including the file in your build config as shown below:

```
#include "../secrets.xcconfig"
```

### Automation

In order for your app to build/ run/ test successfully on the command line, the same must be done in the github workflows. This requires having the debug token saved in your CI system's secure key store (i.e GitHub Actions' encrypted secrets).

Run a command within your workflow to create a secrets file and input the debug token value.

```
- name: Export AppCheck Secret
env:
APP_CHECK_DEBUG_TOKEN: ${{ secrets.BUILD_APPCHECK_DEBUG_TOKEN }}
run: |
echo APP_CHECK_DEBUG_TOKEN=$APP_CHECK_DEBUG_TOKEN >> ../secrets.xcconfig

```

## Key generation & storage

Currently, this package does not facilitate the storage of keys. This part of assessing the clients integrity is done in-app with the help of the [TokenGeneration module](https://github.com/govuk-one-login/mobile-ios-networking?tab=readme-ov-file#tokengeneration)
