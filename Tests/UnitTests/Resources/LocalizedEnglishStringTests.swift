// swiftlint:disable line_length

import XCTest

final class LocalizedEnglishStringTests: XCTestCase {
    func test_generic_keys() throws {
        XCTAssertEqual("app_closeButton".getEnglishString(),
                       "Close")
        XCTAssertEqual("app_cancelButton".getEnglishString(),
                       "Cancel")
        XCTAssertEqual("app_tryAgainButton".getEnglishString(),
                       "Try again")
        XCTAssertEqual("app_continueButton".getEnglishString(),
                       "Continue")
        XCTAssertEqual("app_agreeButton".getEnglishString(),
                       "Agree")
        XCTAssertEqual("app_disagreeButton".getEnglishString(),
                       "Disagree")
        XCTAssertEqual("app_loadingBody".getEnglishString(),
                       "Loading")
        XCTAssertEqual("app_maybeLaterButton".getEnglishString(),
                       "Maybe later")
        XCTAssertEqual("app_skipButton".getEnglishString(),
                       "Skip")
        XCTAssertEqual("app_enterPasscodeButton".getEnglishString(),
                       "Enter passcode")
        XCTAssertEqual("app_exitButton".getEnglishString(),
                       "Exit")
    }
    
    func test_localAuthPrompt_keys() throws {
        XCTAssertEqual("app_faceId_subtitle".getEnglishString(),
                       "Enter iPhone passcode")
        XCTAssertEqual("app_touchId_subtitle".getEnglishString(),
                       "Unlock to proceed")
    }
    
    func test_signInScreen_keys() throws {
        XCTAssertEqual("app_signInTitle".getEnglishString(),
                       "GOV.UK One Login")
        XCTAssertEqual("app_signInBody".getEnglishString(),
                       "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual("app_signInButton".getEnglishString(),
                       "Sign in")
        XCTAssertEqual("app_extendedSignInButton".getEnglishString(),
                       "Sign in with GOV.UK One Login")
    }
    
    func test_analyticsScreen_keys() throws {
        XCTAssertEqual("app_acceptAnalyticsPreferences_title".getEnglishString(),
                       "Help improve the app by sharing analytics")
        XCTAssertEqual("acceptAnalyticsPreferences_body".getEnglishString(),
                       "You can help the One Login team make improvements by sharing analytics about how you use the app.\n\nThese analytics are anonymous. They show us what is and is not working, and help make the app better.\n\nYou can stop sharing these analytics any time by changing your app settings.")
        XCTAssertEqual("app_privacyNoticeLink".getEnglishString(), "Read more about this in the GOV.UK One Login privacy notice")
    }
    
    func test_unableToLoginErrorScreen_keys() throws {
        XCTAssertEqual("app_signInErrorTitle".getEnglishString(),
                       "There was a problem signing you in")
        XCTAssertEqual("app_signInErrorBody".getEnglishString(),
                       "You can try signing in again.\n\nIf this does not work, you may need to try again later.")
    }
    
    func test_networkConnectionErrorScreen_keys() throws {
        XCTAssertEqual("app_networkErrorTitle".getEnglishString(),
                       "You appear to be offline")
        XCTAssertEqual("app_networkErrorBody".getEnglishString(),
                       "GOV.UK One Login is not available offline. Reconnect to the internet and try again.")
    }
    
    func test_genericErrorScreen_keys() throws {
        XCTAssertEqual("app_somethingWentWrongErrorTitle".getEnglishString(),
                       "Something went wrong")
        XCTAssertEqual("app_somethingWentWrongErrorBody".getEnglishString(),
                       "Try again later.")
    }
    
    func test_passcodeInformationScreen_keys() throws {
        XCTAssertEqual("app_noPasscodeSetupTitle".getEnglishString(),
                       "It looks like this phone does not have a passcode")
        XCTAssertEqual("app_noPasscodeSetupBody".getEnglishString(),
                       "Setting a passcode on your phone adds further security. You can then sign into the app this way instead of with your email address and password.\n\nYou can set a passcode later by going to your phone settings.")
    }
    
    func test_faceIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_enableFaceIDTitle".getEnglishString(),
                       "Unlock the app with Face ID")
        XCTAssertEqual("app_enableFaceIDBody".getEnglishString(),
                       "You can use Face ID to unlock the app within 30 minutes of signing in with GOV.UK One Login.\n\nIf you allow Face ID, anyone who can unlock your phone with their face or with your phone's passcode will be able to access your app.")
        XCTAssertEqual("app_enableFaceIDButton".getEnglishString(),
                       "Allow Face ID")
    }
    
    func test_touchIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_enableTouchIDTitle".getEnglishString(),
                       "Unlock the app with Touch ID")
        XCTAssertEqual("app_enableTouchIDBody".getEnglishString(),
                       "You can use your fingerprint to unlock the app within 30 minutes of signing in with GOV.UK One Login.\n\nIf you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone's passcode will be able to access your app.")
        XCTAssertEqual("app_enableTouchIDEnableButton".getEnglishString(),
                       "Allow Touch ID")
    }
    
    func test_unlockScreenKeys() {
        XCTAssertEqual("app_unlockButton".getEnglishString(),
                       "Unlock")
    }
    
    func test_homeScreenKeys() {
        XCTAssertEqual("app_homeTitle".getEnglishString(),
                       "Home")
        XCTAssertEqual("app_displayEmail".getEnglishString(),
                       "You’re signed in as\n%@")
    }
    
    func test_walletScreenKeys() {
        XCTAssertEqual("app_walletTitle".getEnglishString(),
                       "Wallet")
    }
    
    func test_profileScreenKeys() {
        XCTAssertEqual("app_profileTitle".getEnglishString(),
                       "Profile")
        XCTAssertEqual("app_profileSubtitle1".getEnglishString(),
                       "Your details")
        XCTAssertEqual("app_manageSignInDetailsLink".getEnglishString(),
                       "Manage sign in details")
        XCTAssertEqual("app_manageSignInDetailsFootnote".getEnglishString(),
                       "Manage your sign in details with the GOV.UK One Login web service. You’ll need to sign in again.")
        XCTAssertEqual("app_signInDetails".getEnglishString(),
                       "Sign in details")
        XCTAssertEqual("app_profileSubtitle2".getEnglishString(),
                       "Legal")
        XCTAssertEqual("app_privacyNoticeLink2".getEnglishString(),
                       "GOV.UK One Login privacy notice")
        XCTAssertEqual("app_profileSubtitle3".getEnglishString(),
                       "Help and feedback")
        XCTAssertEqual("app_reportAProblemGiveFeedbackLink".getEnglishString(),
                       "Report a problem or give feedback")
        XCTAssertEqual("app_appGuidanceLink".getEnglishString(),
                       "Guidance about using the app")
        XCTAssertEqual("app_signOutButton".getEnglishString(),
                       "Sign out")
    }
    
    func test_signOutPageKeys() {
        XCTAssertEqual("app_signOutConfirmationTitle".getEnglishString(),
                       "Signing out will delete your app data")
        XCTAssertEqual("app_signOutConfirmationBody1".getEnglishString(),
                       "When you sign out, all the information and documents saved in your app will be deleted, including:")
        XCTAssertEqual("app_signOutConfirmationBullet1".getEnglishString(),
                       "any documents saved in your GOV.UK Wallet")
        XCTAssertEqual("app_signOutConfirmationBullet2".getEnglishString(),
                       "your settings for signing in")
        XCTAssertEqual("app_signOutConfirmationBullet3".getEnglishString(),
                       "your analytics sharing preferences")
        XCTAssertEqual("app_signOutConfirmationBody2".getEnglishString(),
                       "This is to keep your information secure.")
        XCTAssertEqual("app_signOutConfirmationBody3".getEnglishString(),
                       "Any deleted documents will still be available online for you to add to your GOV.UK Wallet again.")
        XCTAssertEqual("app_signOutAndDeleteAppDataButton".getEnglishString(),
                       "Sign out and delete app data")
    }
    
    func test_signOutErrorPageKeys() {
        XCTAssertEqual("app_signOutErrorTitle".getEnglishString(),
                       "There was a problem signing you out")
        XCTAssertEqual("app_signOutErrorBody".getEnglishString(),
                       "You can force sign out by deleting the app from your device.")
    }
    
    func test_signOutWarningPageKeys() {
        XCTAssertEqual("app_signOutWarningTitle".getEnglishString(),
                       "You’ve been signed out")
        XCTAssertEqual("app_signOutWarningBody".getEnglishString(),
                       "This is to keep the information in your GOV.UK One Login app secure.\n\nYou need to sign in again to continue.")
    }
    
    func test_dataDeletedWarningPageKeys() {
        XCTAssertEqual("app_dataDeletionWarningBody".getEnglishString(),
                       "We’ve deleted the information in your GOV.UK One Login app because we cannot confirm your sign in details.\n\nWe did this to reduce the risk that someone else will see your information.\n\nTo keep using the app, you’ll need to sign in. You’ll then be asked to set your analytics and sign in preferences again.")
    }

    func test_updateAppPageKeys() {
        XCTAssertEqual("app_updateAppTitle".getEnglishString(),
                       "You need to update your app")
        XCTAssertEqual("app_updateAppBody".getEnglishString(),
                       "You’re using an old version of the GOV.UK One Login app.\n\nUpdate your app to continue.")
        XCTAssertEqual("app_updateAppButton".getEnglishString(),
                       "Update GOV.UK One Login app")
    }
    
    func test_yourServiceTile() {
        XCTAssertEqual("app_yourServicesCardTitle".getEnglishString(),
                       "Your services")
        XCTAssertEqual("app_yourServicesCardBody".getEnglishString(),
                       "See and access the services you’ve used with GOV.UK One Login.")
        XCTAssertEqual("app_yourServicesCardLink".getEnglishString(),
                       "Go to your services")
    }
    
    func test_appUnavailablePageKeys() {
        XCTAssertEqual("app_appUnavailableTitle".getEnglishString(),
                       "Sorry, the app is unavailable")
        XCTAssertEqual("app_appUnavailableBody".getEnglishString(),
                       "You cannot use the GOV.UK One Login app at the moment.\n\nTry again later.")
    }
}

// swiftlint:enable line_length
