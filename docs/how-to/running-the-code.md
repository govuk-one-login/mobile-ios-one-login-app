# How to Run the Code

## Introduction

This guide shows you how to setup an Android Virtual Device (AVD) and run the application from Xcode.

_Note:_ It is assumed that you have already cloned the git repo to a suitable working directory.

## Selecting an iOS device

At the top of the toolbar in Xcode, next to OneLogin click the device (it might default to `My Mac`) and select an iOS device (iPhone 15, iPhone SE etc)

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of selecting an iOS device simulator in Xcode](assets/running-the-code/select-device.png)

</div> 

## Running the app

From the top toolbar in Xcode, click the play button found in the left hand side of the toolbar:

<div style="width: 100%; max-width: 800px; margin-left: auto; margin-right: auto;">

![Screenshot of the run button in Xcode](assets/running-the-code/run-app.png)

</div> 

Xcode will build the app, install it onto our iOS simulator and then run it for us:

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
