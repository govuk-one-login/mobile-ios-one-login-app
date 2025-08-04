# How To - Running the tests

## Introduction

This guide shows you how to run the Unit, Configuration and UI tests for an iOS app.

- Unit tests test project code and are run in all schemes.
- Configuration tests test configuration-specific values, these values will vary per scheme.
- UI tests test end to end journeys interacting with the app as a physical user would.

## Where are the tests?

The Unit, Configuration and UI tests are located under the `UnitTests`, `ConfigTests` and `UITests` folders respectively, within the `Tests` folder, found on the left hand side in the project directory in Xcode:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot showing the project directory in Xcode](assets/running-the-tests/project-directory.png)

</div>

## How to run the tests

To run all the tests together, click and hold the play button in the top left of the toolbar and select `Test`. Xcode will automatically build and run all tests.

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot showing the project directory in Xcode](assets/running-the-tests/run-tests-button.png)

</div>

Individual tests can be run by going to the desired test file and clicking the button to the left of the test definition - this can test a whole class, extension or one specific test:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot showing the project directory in Xcode](assets/running-the-tests/individual-test.png)

</div>

## Test results

Navigating to the test icon in the left-hand window of Xcode (at the top of the project directory, there's a mini-toolbar. The test icon will look like the test icon used to run the tests):

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot showing the project directory in Xcode](assets/running-the-tests/test-panel.png)

</div>

Test outcomes will be displayed here, and also in the corresponding test files:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot showing the project directory in Xcode](assets/running-the-tests/test-results.png)

</div>

