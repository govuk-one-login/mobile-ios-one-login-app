#  App Integrity

## Package description

This package contains the logic to implement app integrity checks using [Firebase App Check](https://firebase.google.com/docs/app-check). It therefore encorporates the Firebase SDK as a dependency, along with the Networking module to enable backend requests.

### Configuration


## Key generation & storage

Currently, this package does not facilitate the storage of keys. This part of assessing the clients integrity is done in-app with the help of the [TokenGeneration module](https://github.com/govuk-one-login/mobile-ios-networking?tab=readme-ov-file#tokengeneration)
