import XCTest

final class LoginUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }
}

extension LoginUITests {
    func test_loginHappyPath() throws {
        let sut = try WelcomeScreen.make()
        sut.waitForUnlockScreenNonExistence()
        sut.agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Launch Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.loginButton.label, "Login")
        // Select 'Login' Button
        let loadingScreen = loginModal.tapBrowserLoginButton()
        let homeScreen = loadingScreen.waitForHomeScreen()
        XCTAssertEqual(homeScreen.titleImage.label, "home")
    }
    
    func test_loginCancelPath() throws {
        let sut = try WelcomeScreen.make()
        sut.waitForUnlockScreenNonExistence()
        sut.agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Launch Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.loginButton.label, "Login")
        // Select 'Cancel' Button
        loginModal.tapCancelButton()
        XCTAssertTrue(sut.signInButton.exists)
    }
    
    func test_OAuthLoginError() throws {
        let sut = try WelcomeScreen.make()
        sut.waitForUnlockScreenNonExistence()
        sut.agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.oAuthErrorButton.label, "Redirect with OAuth error")
        // Redirect with OAuth error
        let errorScreen = loginModal.tapBrowserRedirectWithOAuthErrorButton()
        XCTAssertEqual(errorScreen.title.label, "There was a problem signing you in")
        XCTAssertEqual(errorScreen.closeButton.label, "Go back and try again")
    }
    
    func test_noAuthCodeError() throws {
        let sut = try WelcomeScreen.make()
        sut.waitForUnlockScreenNonExistence()
        sut.agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.noAuthCodeButton.label, "Redirect with no auth code returned")
        // Redirect with invalid state
        let errorScreen = loginModal.tapBrowserNoAuthCodeErrorButton()
        XCTAssertEqual(errorScreen.title.label, "There was a problem signing you in")
        XCTAssertEqual(errorScreen.closeButton.label, "Go back and try again")
    }
    
    func test_fourHundredResponseError() throws {
        let sut = try WelcomeScreen.make()
        sut.waitForUnlockScreenNonExistence()
        sut.agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.fourHundredResponseErrorButton.label, "Set up 400 response from /token")
        // Set up 400 response from /token
        let loginModalSecondScreen = loginModal.tapBrowserFourHundredResponseErrorButton()
        XCTAssertEqual(loginModalSecondScreen.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModalSecondScreen.loginButton.label, "Login")
        // Second Modal Screen
        let errorScreen = loginModalSecondScreen.tapBrowserLoginButton()
        XCTAssertEqual(errorScreen.title.label, "There was a problem signing you in")
        XCTAssertEqual(errorScreen.closeButton.label, "Go back and try again")
    }
    
    func test_fiveHundredResponseError() throws {
        let sut = try WelcomeScreen.make()
        sut.waitForUnlockScreenNonExistence()
        sut.agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.fiveHundredResponseErrorButton.label, "Set up 500 response from /token")
        // Set up 500 response from /token
        let loginModalSecondScreen = loginModal.tapBrowserFiveHundredResponseErrorButton()
        XCTAssertEqual(loginModalSecondScreen.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModalSecondScreen.loginButton.label, "Login")
        // Second Modal Screen
        let errorScreen = loginModalSecondScreen.tapBrowserLoginButton()
        XCTAssertEqual(errorScreen.title.label, "There was a problem signing you in")
        XCTAssertEqual(errorScreen.closeButton.label, "Go back and try again")
    }
}
