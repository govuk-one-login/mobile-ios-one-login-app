import XCTest

final class LoginUITests: XCTestCase {
    var sut: WelcomeScreen!
    
    override func setUp() async throws {
        await MainActor.run {
            sut = WelcomeScreen()
            guard let debugToken = ProcessInfo.processInfo.environment["FIRAAppCheckDebugToken"] else {
                preconditionFailure("No Firebase App Check Debug Token passed in environment")
            }
            sut.app.launchEnvironment["FIRAAppCheckDebugToken"] = debugToken
            sut.app.launch()
            let exp = expectation(description: "Waiting once App has launched")
            XCTWaiter().wait(for: [exp], timeout: 30)
        }
    }
    
    override func tearDown() {
        sut.app.terminate()
        sut = nil
    }
    
    func agreeIfAnalytics() {
        if sut.app.staticTexts["Help improve the app by sharing analytics"].exists {
            let analyticsButton = sut.app.buttons["Share analytics"]
            XCTAssertTrue(analyticsButton.exists)
            // Tap Analytics Permission Button
            analyticsButton.tap()
        }
    }
}

extension LoginUITests {
    func test_loginHappyPath() throws {
        agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
        XCTAssertEqual(sut.signInButton.label, "Sign in with GOV.UK One Login")
        // Launch Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.loginButton.label, "Login")
        // Select 'Login' Button
        let homeScreen = loginModal.tapBrowserLoginButton()
        XCTAssertEqual(homeScreen.titleImage.label, "home")
    }
    
    func test_loginCancelPath() throws {
        agreeIfAnalytics()
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
        XCTAssertTrue(sut.isVisible)
    }
    
    func test_OAuthLoginError() throws {
        agreeIfAnalytics()
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
        agreeIfAnalytics()
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
        agreeIfAnalytics()
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
        agreeIfAnalytics()
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
