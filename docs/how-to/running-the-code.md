# How to Run the Code

## Introduction

This guide shows you how to select a scheme, simulator and run the application from Xcode.

_Note:_ It is assumed that you have already cloned the git repo to a suitable working directory.

## Selecting an iOS device

At the top of the toolbar in Xcode, select a scheme to run your app in (options are "OneLogin" for a Release configuration, "OneLoginStaging" for a Staging configuration and "OneLoginBuild" for a Build configuration), click the device (it might default to `My Mac`) and select an iOS device (iPhone 15, iPhone SE etc)

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of selecting an scheme in Xcode](assets/running-the-code/scheme-choosing.png)

</div>

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of selecting an iOS device simulator in Xcode](assets/running-the-code/select-device.png)

</div>

## Running the app

From the top toolbar in Xcode, click the play button found on the left hand side of the toolbar:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of the run button in Xcode](assets/running-the-code/run-app.png)

</div>

Xcode will build the app, install it onto the iOS simulator and then run it:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of Xcode showing the Gradle Build progress bar](assets/running-the-code/app-building.png)

</div>

Once the task has finished, you should see the landing screen of the app in the iOS simulator:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of Xcode showing the app running on the iPhone simulator](assets/running-the-code/simulator-loaded.png)

</div>

To stop the simulator from running the app, you can click the stop button found to the left of the play button:

 <div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of Xcode's stop button](assets/running-the-code/stop-button.png)

</div>
