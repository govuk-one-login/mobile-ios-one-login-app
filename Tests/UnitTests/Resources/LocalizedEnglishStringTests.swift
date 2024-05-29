// swiftlint:disable line_length

@testable import OneLogin
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
        XCTAssertEqual("app_enterPasscodeButton".getEnglishString(),
                       "Enter passcode")
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
    }
    
    func test_analyticsScreen_keys() throws {
        XCTAssertEqual("app_acceptAnalyticsPreferences_title".getEnglishString(),
                       "Help improve the app by sharing analytics")
        XCTAssertEqual("acceptAnalyticsPreferences_body".getEnglishString(),
                       "You can help us improve this app by choosing to automatically share app activity and analytics data.\n\nThis is optional and lets us understand how people use this service so we can make it better.\n\nYou can change your preferences at any time in your Settings.")
        XCTAssertEqual("app_privacyNoticeLink".getEnglishString(), "View GOV.UK One Login privacy notice")
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
    
    func test_faceIDEnrollmentScreen_keys() throws {
        XCTAssertEqual("app_enableFaceIDTitle".getEnglishString(),
                       "Use Face ID to sign in")
        XCTAssertEqual("app_enableFaceIDBody".getEnglishString(),
                       "Sign in with your face instead of your email address and password. Your Face ID is not shared with GOV.UK One Login.")
        XCTAssertEqual("app_enableFaceIDFootnote".getEnglishString(),
                       "If you use Face ID, anyone with a Face ID saved to your phone will be able to sign in to this app.")
        XCTAssertEqual("app_enableFaceIDButton".getEnglishString(),
                       "Use Face ID")
    }
    
    func test_touchIDEnrollmentScreen_keys() throws {
        XCTAssertEqual("app_enableTouchIDTitle".getEnglishString(),
                       "Use Touch ID to sign in")
        XCTAssertEqual("app_enableTouchIDBody".getEnglishString(),
                       "Sign in with your fingerprint instead of your email address and password. Your Touch ID is not shared with GOV.UK One Login.")
        XCTAssertEqual("app_enableTouchIDFootnote".getEnglishString(),
                       "If you use Touch ID, anyone with a Touch ID saved to your phone will be able to sign in to this app.")
        XCTAssertEqual("app_enableTouchIDEnableButton".getEnglishString(),
                       "Use Touch ID")
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
}

// swiftlint:enable line_length

// "app_appGuidanceLink" = "Guidance about using the app";
//
// "app_signOutButton" = "Sign out";
