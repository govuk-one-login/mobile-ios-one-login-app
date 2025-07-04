// swiftlint:disable line_length

import XCTest

final class LocalizedEnglishStringTests: XCTestCase {
    func test_generic_keys() throws {
        XCTAssertEqual("app_closeButton".getEnglishString(),
                       "Close")
        XCTAssertEqual("app_cancelButton".getEnglishString(),
                       "Cancel")
        XCTAssertEqual("app_tryAgainButton".getEnglishString(),
                       "Go back and try again")
        XCTAssertEqual("app_continueButton".getEnglishString(),
                       "Continue")
        XCTAssertEqual("app_agreeButton".getEnglishString(),
                       "Agree")
        XCTAssertEqual("app_disagreeButton".getEnglishString(),
                       "Disagree")
        XCTAssertEqual("app_loadingBody".getEnglishString(),
                       "Loading")
        XCTAssertEqual("app_skipButton".getEnglishString(),
                       "Skip")
        XCTAssertEqual("app_enterPasscodeButton".getEnglishString(),
                       "Enter passcode")
        XCTAssertEqual("app_exitButton".getEnglishString(),
                       "Exit")
        XCTAssertEqual("app_nameString".getEnglishString(),
                       "GOV.UK One Login")
    }
    
    func test_localAuthPrompt_keys() throws {
        XCTAssertEqual("app_faceId_subtitle".getEnglishString(),
                       "Enter iPhone passcode")
        XCTAssertEqual("app_touchId_subtitle".getEnglishString(),
                       "Unlock to proceed")
    }
    
    func test_signInScreen_keys() throws {
        XCTAssertEqual("app_signInBody".getEnglishString(),
                       "Prove your identity to access government services.\n\nYou’ll need to sign in with your %@ details.")
        XCTAssertEqual("app_signInButton".getEnglishString(),
                       "Sign in")
        XCTAssertEqual("app_extendedSignInButton".getEnglishString(),
                       "Sign in with %@")
    }
    
    func test_analyticsScreen_keys() throws {
        XCTAssertEqual("app_acceptAnalyticsPreferences_title".getEnglishString(),
                       "Help improve the app by sharing analytics")
        XCTAssertEqual("acceptAnalyticsPreferences_body".getEnglishString(),
                       "You can help the %@ team make improvements by sharing analytics about how you use the app.\n\nThese analytics are anonymous. They show us what is and is not working, and help make the app better.\n\nYou can stop sharing these analytics any time by changing your app settings.")
        XCTAssertEqual("app_privacyNoticeLink".getEnglishString(), "Read more about this in the %@ privacy notice")
    }
    
    func test_unableToLoginErrorScreen_keys() throws {
        XCTAssertEqual("app_signInErrorTitle".getEnglishString(),
                       "There was a problem signing you in")
        XCTAssertEqual("app_signInErrorBody".getEnglishString(),
                       "You can try signing in again.\n\nIf this does not work, you may need to try again later.")
    }
    
    func test_networkConnectionErrorScreen_keys() throws {
        XCTAssertEqual("app_networkErrorTitle".getEnglishString(),
                       "You are not connected to the internet")
        XCTAssertEqual("app_networkErrorBody".getEnglishString(),
                       "You need to have an internet connection to use %@.\n\nReconnect to the internet and try again.")
    }
    
    func test_genericErrorScreen_keys() throws {
        XCTAssertEqual("app_genericErrorPage".getEnglishString(),
                       "Sorry, there’s a problem")
        XCTAssertEqual("app_genericErrorPageBody".getEnglishString(),
                       "Try again later.")
    }
    
    func test_faceIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_FaceID".getEnglishString(),
                       "Face ID")
        XCTAssertEqual("app_enableFaceIDBody".getEnglishString(),
                       "You can use Face ID to unlock the app within 30 minutes of signing in with %@.\n\nIf you allow Face ID, anyone who can unlock your phone with their face or with your phone's passcode will be able to access your app.")
        XCTAssertEqual("app_enableBiometricsFaceIDBody2".getEnglishString(),
                       "If you allow Face ID, anyone who can unlock your phone with their face or with your phone's passcode will be able to access your app.\n\nYou can turn off Face ID for this app anytime in your phone settings.")
    }
    
    func test_touchIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_TouchID".getEnglishString(),
                       "Touch ID")
        XCTAssertEqual("app_enableTouchIDBody".getEnglishString(),
                       "You can use your fingerprint to unlock the app within 30 minutes of signing in with %@.\n\nIf you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone's passcode will be able to access your app.")
        XCTAssertEqual("app_enableBiometricsTouchIDBody2".getEnglishString(),
                       "If you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone's passcode will be able to access your app.")
    }
    
    func test_biometricsEnrolmentScreen_commonKeys() throws {
        XCTAssertEqual("app_enableLoginBiometricsTitle".getEnglishString(),
                       "Unlock the app with %@")
        XCTAssertEqual("app_enableBiometricsButton".getEnglishString(),
                       "Allow %@")
        XCTAssertEqual("app_enableBiometricsTitle".getEnglishString(),
                       "Allow %@")
        XCTAssertEqual("app_enableBiometricsBody1".getEnglishString(),
                       "Use %@ to:")
        XCTAssertEqual("app_enableBiometricsBullet1".getEnglishString(),
                       "unlock the app within 30 minutes of signing in with %@")
        XCTAssertEqual("app_enableBiometricsBullet2".getEnglishString(),
                       "view and add documents")
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
        XCTAssertEqual("app_tabBarWallet".getEnglishString(),
                       "Documents")
    }
    
    func test_settingsScreenKeys() {
        XCTAssertEqual("app_settingsTitle".getEnglishString(),
                       "Settings")
        XCTAssertEqual("app_settingsSignInDetailsTile".getEnglishString(),
                       "Your %@")
        XCTAssertEqual("app_settingsSignInDetailsLink".getEnglishString(),
                       "Manage your sign in details")
        XCTAssertEqual("app_settingsSignInDetailsFootnote".getEnglishString(),
                       "You might need to sign in again to manage your %@ details.")
        XCTAssertEqual("app_privacyNoticeLink2".getEnglishString(),
                       "%@ privacy notice")
        XCTAssertEqual("app_settingsSubtitle1".getEnglishString(),
                       "Help and feedback")
        XCTAssertEqual("app_contactLink".getEnglishString(),
                       "Contact %@")
        XCTAssertEqual("app_appGuidanceLink".getEnglishString(),
                       "Using the %@ app")
        XCTAssertEqual("app_signOutButton".getEnglishString(),
                       "Sign out")
        XCTAssertEqual("app_settingsSubtitle2".getEnglishString(),
                       "About the app")
        XCTAssertEqual("app_settingsAnalyticsToggle".getEnglishString(),
                       "Share app analytics")
        XCTAssertEqual("app_settingsAnalyticsToggleFootnote".getEnglishString(),
                       "You can share anonymous analytics about how you use the app to help the %@ team make improvements. Read more in the %@ privacy notice.")
        XCTAssertEqual("app_accessibilityStatement".getEnglishString(),
                       "Accessibility statement")
    }
    
    func test_signOutPageKeys() {
        XCTAssertEqual("app_signOutConfirmationTitle".getEnglishString(),
                       "Are you sure you want to sign out?")
        XCTAssertEqual("app_signOutConfirmationBody1".getEnglishString(),
                       "If you sign out, the information saved in your app will be deleted. This is to reduce the risk that someone else will see your information.")
        XCTAssertEqual("app_signOutConfirmationBody2".getEnglishString(),
                       "This means:")
        XCTAssertEqual("app_signOutConfirmationBullet1".getEnglishString(),
                       "any documents in your app will be removed")
        XCTAssertEqual("app_signOutConfirmationBullet2".getEnglishString(),
                       "if you’re using Face ID or Touch ID to unlock the app, this will be switched off")
        XCTAssertEqual("app_signOutConfirmationBullet3".getEnglishString(),
                       "you’ll stop sharing analytics about how you use the app")
        XCTAssertEqual("app_signOutConfirmationBody3".getEnglishString(),
                       "Next time you sign in, you’ll be able to add your documents again and reset your preferences.")
        XCTAssertEqual("app_signOutAndDeleteAppDataButton".getEnglishString(),
                       "Sign out and delete information")
    }
    
    func test_signOutSuccessfulPageKeys() {
        XCTAssertEqual("app_signedOutTitle".getEnglishString(),
                       "You have signed out")
        XCTAssertEqual("app_signedOutBodyWithWallet".getEnglishString(),
                       "To keep your information secure, any documents in this app have been removed and your preferences have been reset.\n\nYou need to sign in and reset your preferences to continue using the app. You’ll then be able to add your documents again.")
        XCTAssertEqual("app_signedOutBodyNoWallet".getEnglishString(),
                       "To keep your information secure, your app preferences have been reset.\n\nYou need to sign in and set your preferences again to continue using the app.")
    }
    
    func test_signOutErrorPageKeys() {
        XCTAssertEqual("app_signOutErrorTitle".getEnglishString(),
                       "There was a problem signing you out")
        XCTAssertEqual("app_signOutErrorBody".getEnglishString(),
                       "You can force sign out by deleting the app from your device.")
    }
    
    func test_signOutWarningPageKeys() {
        XCTAssertEqual("app_signOutWarningTitle".getEnglishString(),
                       "You need to sign in again")
        XCTAssertEqual("app_signOutWarningBody".getEnglishString(),
                       "It’s been more than 30 minutes since you last signed in to the %@ app.\n\nSign in again to continue.")
    }
    
    func test_dataDeletedWarningPageKeys() {
        XCTAssertEqual("app_dataDeletionWarningTitle".getEnglishString(),
                       "Something went wrong")
        
        XCTAssertEqual("app_dataDeletionWarningBody".getEnglishString(),
                       "We could not confirm your sign in details.\n\nTo keep your information secure, any documents in your app have been removed and your preferences have been reset.\n\nYou need to sign in and reset your preferences to continue using the app. You’ll then be able to add your documents again.")
        
        XCTAssertEqual("app_dataDeletionWarningBodyNoWallet".getEnglishString(),
                       "We could not confirm your sign in details.\n\nTo keep your information secure, your preference for using Touch ID or Face ID to unlock the app has been reset.\n\nYou need to sign in and set your preferences again to continue using the app.")
    }

    func test_updateAppPageKeys() {
        XCTAssertEqual("app_updateAppTitle".getEnglishString(),
                       "You need to update your app")
        XCTAssertEqual("app_updateAppBody".getEnglishString(),
                       "You’re using an old version of the %@ app.\n\nUpdate your app to continue.")
        XCTAssertEqual("app_updateAppButton".getEnglishString(),
                       "Update %@ app")
    }
    
    func test_homeTileKeys() {
        XCTAssertEqual("app_welcomeTileHeader".getEnglishString(),
                       "Welcome")
        XCTAssertEqual("app_welcomeTileBody1".getEnglishString(),
                       "You can use this app to prove your identity to access some government services.")
        XCTAssertEqual("app_appPurposeTileHeader".getEnglishString(),
                       "How to prove your identity")
        XCTAssertEqual("app_appPurposeTileBody1".getEnglishString(),
                       "If you need to prove your identity with %@ to access a service, you'll be asked to open this app. It works by matching your face to your photo ID.")
    }
    
    func test_appUnavailablePageKeys() {
        XCTAssertEqual("app_appUnavailableTitle".getEnglishString(),
                       "Sorry, the app is unavailable")
        XCTAssertEqual("app_appUnavailableBody".getEnglishString(),
                       "You cannot use the %@ app at the moment.\n\nTry again later.")
    }
    
    func test_accessibilityHintKeys() {
        XCTAssertEqual("app_externalBrowser".getEnglishString(), "Opens in web browser")
        XCTAssertEqual("app_externalApp".getEnglishString(), "Opens in App Store")
        XCTAssertEqual("app_loadingLabel".getEnglishString(), "Loading %@")
    }
    
    func test_localAuthSettingsError_keys() throws {
        XCTAssertEqual("app_localAuthManagerErrorTitle".getEnglishString(),
                       "You need to update your phone settings")
        XCTAssertEqual("app_localAuthManagerErrorBody1".getEnglishString(),
                       "To add documents to your %@, you need to protect your phone with a passcode.\n\nThis is to make sure no one else can view or add documents to your wallet.")
        XCTAssertEqual("app_localAuthManagerErrorBody3".getEnglishString(),
                       "You need to:")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList1FaceID".getEnglishString(),
                       "Go to Face ID & Passcode in your phone settings.")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList1TouchID".getEnglishString(),
                       "Go to Touch ID & Passcode in your phone settings.")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList2".getEnglishString(),
                       "Tap Turn Passcode On and follow the instructions.")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList3".getEnglishString(),
                       "Come back to continue using your %@.")
        XCTAssertEqual("app_localAuthManagerErrorGoToSettingsButton".getEnglishString(),
                       "Go to phone settings")
    }
    
    func test_localAuthBiometricsError_keys() throws {
        XCTAssertEqual("app_localAuthManagerBiometricsErrorTitle".getEnglishString(),
                       "You need to allow %@")
        XCTAssertEqual("app_localAuthManagerBiometricsFaceIDErrorBody".getEnglishString(),
                       "To add documents to your GOV.UK Wallet, you need to allow Face ID. This is to keep your documents secure.\n\nWhen you allow Face ID, anyone who can unlock your phone with their face or with your phone's passcode will be able to access your app.\n\nYou can turn off Face ID for this app anytime in your phone’s settings.")
        XCTAssertEqual("app_localAuthManagerBiometricsTouchIDErrorBody".getEnglishString(),
                       "To add documents to your GOV.UK Wallet, you need to allow Touch ID. This is to keep your documents secure.\n\nWhen you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone's passcode will be able to access your app.")
    }
}

// swiftlint:enable line_length
