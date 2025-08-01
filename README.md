# One Login - iOS Mobile App

This repository hosts the iOS Mobile app for One Login as part of Digital Identity. It also accomodates the ID Check SDK for proving your identity and the Wallet SDK for credential issuance. 


## Getting started

A number of how-to documents are provided to get a new developer up to speed with:
- [pre-requisite software](docs/required-software.md)
- [running the code](docs/running-the-code.md)
- [running the tests](docs/running-the-tests.md)
- [ways of working](docs/ways-of-working.md)


## Local Packages

- App Integrity - contains the logic to implement app integrity checks.
- Local Authentication Wrapper - wraps [Apple's Local Authentication framework](https://developer.apple.com/documentation/localauthentication) for easier use.
- Mobile Platform Services - seperates backend API calls for a cleaner One Login codebase.

## Git Submodules

This package makes use of [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for some of it's dependencies.

A git submodule works as a separate, linked repository within your repository, tied to a commit.

### Working with submodules in this package

The submodules we are using are private repositories so you will need to authenticate through SSH to pull them down.

In terminal, run the following command and authenticate with GitHub through the GitHub CLI:

`gh auth login`

You can clone the project along with submodules using the following command:

`git clone --recurse-submodules https://github.com/govuk-one-login/mobile-ios-one-login-app`

If you have cloned the project previously or pulled the project without the `--recurse-submodules` flag you will also need to pull the submodule to run the code locally.

Once you have successfully authenticated with GitHUb through SSH you can pull the submodule through running the following command at the project root:

`git submodule update --init`

For subsequent pulls of the submodule you can omit the `--init` flag:

`git submodule update`

If you want to update to the latest version of the Wallet SDK, you can use:

`git submodule update --remote`
