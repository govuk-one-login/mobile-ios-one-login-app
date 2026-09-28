// swiftlint:disable line_length

import Testing

// swiftlint:disable type_body_length
struct LocalizedEnglishStringTests {
    @Test
    func test_generic_keys() {
        #expect("app_closeButton".getEnglishString() ==
                       "Close")
        #expect("app_cancelButton".getEnglishString() ==
                       "Cancel")
        #expect("app_doneButton".getEnglishString() ==
                       "Done")
        #expect("app_tryAgainButton".getEnglishString() ==
                       "Go back and try again")
        #expect("app_continueButton".getEnglishString() ==
                       "Continue")
        #expect("app_agreeButton".getEnglishString() ==
                       "Agree")
        #expect("app_disagreeButton".getEnglishString() ==
                       "Disagree")
        #expect("app_loadingBody".getEnglishString() ==
                       "Loading")
        #expect("app_skipButton".getEnglishString() ==
                       "Skip")
        #expect("app_enterPasscodeButton".getEnglishString() ==
                       "Enter passcode")
        #expect("app_exitButton".getEnglishString() ==
                       "Exit")
        #expect("app_nameString".getEnglishString() ==
                       "GOV.UK One Login")
    }
    
    @Test
    func test_localAuthPrompt_keys() {
        #expect("app_faceId_subtitle".getEnglishString() ==
                       "Enter iPhone passcode")
        #expect("app_touchId_subtitle".getEnglishString() ==
                       "Unlock to proceed")
    }
    
    @Test
    func test_signInScreen_keys() {
        #expect("app_signInBody".getEnglishString() ==
                       "Prove your identity to access government services.\n\nYou’ll need to sign in with your %@ details.")
        #expect("app_signInButton".getEnglishString() ==
                       "Sign in")
        #expect("app_extendedSignInButton".getEnglishString() ==
                       "Sign in with %@")
    }
    
    @Test
    func test_analyticsScreen_keys() {
        #expect("app_acceptAnalyticsPreferences_title".getEnglishString() ==
                       "Help improve the app by sharing analytics")
        #expect("acceptAnalyticsPreferences_body".getEnglishString() ==
                       "You can help the %@ team make improvements by sharing analytics about how you use the app.\n\nThese analytics are anonymous. They show us what is and is not working, and help make the app better.\n\nYou can stop sharing these analytics any time by changing your app settings.")
        #expect("app_privacyNoticeLink".getEnglishString() == "Read more about this in the %@ privacy notice")
    }
    
    @Test
    func test_unableToLoginErrorScreen_keys() {
        #expect("app_signInErrorTitle".getEnglishString() ==
                       "There was a problem signing you in")
        #expect("app_signInErrorRecoverableBody".getEnglishString() ==
                       "Try to sign in again.")
        #expect("app_signInErrorUnrecoverableBody".getEnglishString() ==
                       "Try again later.")
    }
    
    @Test
    func test_networkConnectionErrorScreen_keys() {
        #expect("app_networkErrorTitle".getEnglishString() ==
                       "You are not connected to the internet")
        #expect("app_networkErrorBody".getEnglishString() ==
                       "You need to have an internet connection to use %@.\n\nReconnect to the internet and try again.")
    }
    
    @Test
    func test_genericErrorScreen_keys() {
        #expect("app_genericErrorPage".getEnglishString() ==
                       "Sorry, there’s a problem")
        #expect("app_genericErrorPageBody".getEnglishString() ==
                       "Try again later.")
    }
    
    @Test
    func test_faceIDEnrolmentScreen_keys() {
        #expect("app_FaceID".getEnglishString() ==
                       "Face ID")
        #expect("app_enableBiometricsFaceIDBody2".getEnglishString() ==
                       "If you allow Face ID, anyone who can unlock your phone with their face or with your phone's passcode will be able to access your app.\n\nYou can turn off Face ID for this app anytime in your phone settings.")
    }
    
    @Test
    func test_touchIDEnrolmentScreen_keys() {
        #expect("app_TouchID".getEnglishString() ==
                       "Touch ID")
        #expect("app_enableBiometricsTouchIDBody2".getEnglishString() ==
                       "If you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone's passcode will be able to access your app.")
    }
    
    @Test
    func test_biometricsEnrolmentScreen_commonKeys() {
        #expect("app_enableBiometricsButton".getEnglishString() ==
                       "Allow %@")
        #expect("app_enableBiometricsTitle".getEnglishString() ==
                       "Allow %@")
        #expect("app_enableBiometricsBody1".getEnglishString() ==
                       "Use %@ to:")
        #expect("app_enableBiometricsBullet1".getEnglishString() ==
                       "sign in")
        #expect("app_enableBiometricsBullet2".getEnglishString() ==
                       "view and add documents")
    }
    
    @Test
    func test_unlockScreenKeys() {
        #expect("app_unlockButton".getEnglishString() ==
                       "Unlock")
    }
    
    @Test
    func test_homeScreenKeys() {
        #expect("app_homeTitle".getEnglishString() ==
                       "Home")
        #expect("app_displayEmail".getEnglishString() ==
                       "You’re signed in as\n%@")
    }
    
    @Test
    func test_walletScreenKeys() {
        #expect("app_tabBarWallet".getEnglishString() ==
                       "Documents")
    }
    
    @Test
    func test_settingsScreenKeys() {
        #expect("app_settingsTitle".getEnglishString() ==
                       "Settings")
        #expect("app_settingsSignInDetailsTile".getEnglishString() ==
                       "Your %@")
        #expect("app_settingsSignInDetailsLink".getEnglishString() ==
                       "Manage your sign in details")
        #expect("app_settingsSignInDetailsFootnote".getEnglishString() ==
                       "You might need to sign in again to manage your %@ details.")
        #expect("app_privacyNoticeLink2".getEnglishString() ==
                       "%@ privacy notice")
        #expect("app_settingsSubtitle1".getEnglishString() ==
                       "Help and feedback")
        #expect("app_contactLink".getEnglishString() ==
                       "Contact %@")
        #expect("app_appGuidanceLink".getEnglishString() ==
                       "Using the %@ app")
        #expect("app_proveYourIdentityLink".getEnglishString() ==
                       "Proving your identity")
        #expect("app_addDocumentsLink".getEnglishString() ==
                       "Adding documents to your app")
        #expect("app_signOutButton".getEnglishString() ==
                       "Sign out")
        #expect("app_settingsSubtitle2".getEnglishString() ==
                       "About the app")
        #expect("app_settingsAnalyticsToggle".getEnglishString() ==
                       "Share app analytics")
        #expect("app_settingsAnalyticsToggleFootnote".getEnglishString() ==
                       "You can share anonymous analytics about how you use the app to help the %@ team make improvements. Read more in the %@ privacy notice.")
        #expect("app_accessibilityStatement".getEnglishString() ==
                       "Accessibility statement")
        #expect("app_termsAndConditionsLink".getEnglishString() ==
                       "Terms and conditions")
    }
    
    @Test
    func test_signOutPageKeys() {
        #expect("app_signOutConfirmationTitle".getEnglishString() ==
                       "Are you sure you want to sign out?")
        #expect("app_signOutConfirmationBody1".getEnglishString() ==
                       "If you sign out, the information saved in your app will be deleted. This is to reduce the risk that someone else will see your information.")
        #expect("app_signOutConfirmationBody2".getEnglishString() ==
                       "This means:")
        #expect("app_signOutConfirmationBullet1".getEnglishString() ==
                       "any documents in your app will be removed")
        #expect("app_signOutConfirmationBullet2".getEnglishString() ==
                       "if you’re using Face ID or Touch ID to unlock the app, this will be switched off")
        #expect("app_signOutConfirmationBullet3".getEnglishString() ==
                       "you’ll stop sharing analytics about how you use the app")
        #expect("app_signOutConfirmationBody3".getEnglishString() ==
                       "Next time you sign in, you’ll be able to add your documents again and reset your preferences.")
        #expect("app_signOutAndDeleteAppDataButton".getEnglishString() ==
                       "Sign out and delete information")
    }
    
    @Test
    func test_signOutSuccessfulPageKeys() {
        #expect("app_signedOutTitle".getEnglishString() ==
                       "You have signed out")
        #expect("app_signedOutBody".getEnglishString() ==
                       "To keep your information secure, any documents in this app have been removed and your preferences have been reset.\n\nYou need to sign in and reset your preferences to continue using the app. You’ll then be able to add your documents again.")
    }
    
    @Test
    func test_signOutErrorPageKeys() {
        #expect("app_signOutErrorTitle".getEnglishString() ==
                       "There was a problem signing you out")
        #expect("app_signOutErrorBody".getEnglishString() ==
                       "Try again later.\n\nIf you need to sign out right now, you can delete the app from your phone. This will also delete any documents saved in your app.")
        #expect("app_signOutErrorButton".getEnglishString() ==
                       "Go back to settings")
    }
    
    @Test
    func test_signInAgainPageKeys() {
        #expect("app_signInAgainTitle".getEnglishString() ==
                       "You need to sign in again")
        #expect("app_signInAgainBody".getEnglishString() ==
                       "Sign in with your %@ details to continue.\n\nThis is to keep your information secure.")
    }
    
    @Test
    func test_dataDeletedWarningPageKeys() {
        #expect("app_dataDeletionWarningTitle".getEnglishString() ==
                       "Something went wrong")
        
        #expect("app_dataDeletionWarningBody".getEnglishString() ==
                       "We could not confirm your sign in details.\n\nTo keep your information secure, any documents in your app have been removed and your preferences have been reset.\n\nYou need to sign in and reset your preferences to continue using the app. You’ll then be able to add your documents again.")
    }

    @Test
    func test_updateAppPageKeys() {
        #expect("app_updateAppTitle".getEnglishString() ==
                       "You need to update your app")
        #expect("app_updateAppBody".getEnglishString() ==
                       "You're using an old version of the %@ app.\n\nGo to the App Store and update your app to continue.")
        #expect("app_updateAppButton".getEnglishString() ==
                       "Go to App Store")
    }
    
    @Test
    func test_homeTileKeys() {
        #expect("app_welcomeTileHeader".getEnglishString() ==
                       "Welcome")
        #expect("app_welcomeTileBody1".getEnglishString() ==
                       "You can use this app to prove your identity to access some government services.")
        #expect("app_appPurposeTileHeader".getEnglishString() ==
                       "How to prove your identity")
        #expect("app_appPurposeTileBody1".getEnglishString() ==
                       "To start, go to the GOV.UK website and find the government service you need to use. You'll be asked to open this app if you need it.")
        #expect("app_appPurposeTileButton".getEnglishString() ==
                       "Find out more")
    }
    
    @Test
    func test_proveIdentityGuidanceKeys() {
        #expect("app_proveYourIdentityGuidanceTitle".getEnglishString() ==
                       "How to prove your identity")
        #expect("app_proveYourIdentityGuidanceBody1".getEnglishString() ==
                       "You cannot start proving your identity in this app.\n\nTo start, go to the GOV.UK website and find the government service you need to use.\n\nYou'll be asked to open this app if you need to use it to prove your identity.")
        #expect("app_proveYourIdentityGuidanceLink".getEnglishString() ==
                       "Go to the GOV.UK website")
        #expect("app_proveYourIdentityGuidanceBody2".getEnglishString() ==
                       "If you've already started proving your identity on the GOV.UK website")
        #expect("app_proveYourIdentityGuidanceBody3".getEnglishString() ==
                       "If a service on the GOV.UK website has guided you to open this app, you should see a button to continue proving your identity in the 'Home' section.\n\nIf you cannot see the button, close the app and open it again.")
    }
    
    @Test
    func test_appUnavailablePageKeys() {
        #expect("app_appUnavailableTitle".getEnglishString() ==
                       "Sorry, the app is unavailable")
        #expect("app_appUnavailableBody".getEnglishString() ==
                       "You cannot use the %@ app at the moment.\n\nTry again later.")
    }
    
    @Test
    func test_accessibilityHintKeys() {
        #expect("app_externalBrowser".getEnglishString() == "Opens in web browser")
        #expect("app_externalApp".getEnglishString() == "Opens in App Store")
        #expect("app_loadingLabel".getEnglishString() == "Loading %@")
    }
    
    @Test
    func test_localAuthSettingsError_keys() {
        #expect("app_localAuthManagerErrorTitle".getEnglishString() ==
                       "Update your phone's security settings")
        #expect("app_localAuthManagerErrorBody1".getEnglishString() ==
                       "To add documents, you need to protect your phone with a passcode.\n\nThis is to make sure no one else can view or add documents to your app.")
        #expect("app_localAuthManagerErrorBody3".getEnglishString() ==
                       "You need to:")
        #expect("app_localAuthManagerErrorNumberedList0".getEnglishString() ==
                       "Go to your phone settings.")
        #expect("app_localAuthManagerErrorNumberedList1FaceID".getEnglishString() ==
                       "Tap Face ID & Passcode.")
        #expect("app_localAuthManagerErrorNumberedList1TouchID".getEnglishString() ==
                       "Tap Touch ID & Passcode.")
        #expect("app_localAuthManagerErrorNumberedList2".getEnglishString() ==
                       "Tap Turn Passcode On and follow the instructions.")
        #expect("app_localAuthManagerErrorNumberedList3".getEnglishString() ==
                       "Come back to continue using your documents.")
    }
    
    @Test
    func test_localAuthBiometricsError_keys() {
        #expect("app_localAuthManagerBiometricsErrorTitle".getEnglishString() ==
                       "You need to allow %@")
        #expect("app_localAuthManagerBiometricsFaceIDErrorBody".getEnglishString() ==
                       "To add documents, you need to allow Face ID. This is to keep your documents secure.\n\nWhen you allow Face ID, anyone who can unlock your phone with their face or with your phone's passcode will be able to access your app.\n\nYou can turn off Face ID for this app anytime in your phone’s settings.")
        #expect("app_localAuthManagerBiometricsTouchIDErrorBody".getEnglishString() ==
                       "To add documents, you need to allow Touch ID. This is to keep your documents secure.\n\nWhen you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone's passcode will be able to access your app.")
    }
    
    @Test
    func test_appIntegrityPageKeys() {
        #expect("app_appIntegrityErrorTitle".getEnglishString() ==
                       "Sorry, there’s a problem")
        #expect("app_appIntegrityErrorBody1".getEnglishString() ==
                       "You cannot use the %@ app at the moment.\n\nTry again later.")
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable line_length
