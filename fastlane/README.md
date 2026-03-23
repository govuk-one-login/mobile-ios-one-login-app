fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios buildForTesting

```sh
[bundle exec] fastlane ios buildForTesting
```

Build for testing

### ios testWithoutBuildingWithoutCoverage

```sh
[bundle exec] fastlane ios testWithoutBuildingWithoutCoverage
```

Run Tests without Sonar Coverage

### ios testWithoutCoverage

```sh
[bundle exec] fastlane ios testWithoutCoverage
```

Run Tests without Sonar Coverage

### ios testWithoutCoverageForUITests

```sh
[bundle exec] fastlane ios testWithoutCoverageForUITests
```

Run Tests without Sonar Coverage

### ios testWithoutBuilding

```sh
[bundle exec] fastlane ios testWithoutBuilding
```

Run Tests and Output Code Coverage

### ios prerelease

```sh
[bundle exec] fastlane ios prerelease
```

Push a new beta build to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
