import XCTest

final class LoginUITests: XCTestCase {
    var sut: WelcomeScreen!
    
    override func setUp() async throws {
        await MainActor.run {
            sut = WelcomeScreen()
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
            let analyticsButton = sut.app.buttons["Agree"]
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
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
        // Launch Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.loginButton.label, "Login")
        // Select 'Login' Button
        let homeScreen = loginModal.tapBrowserLoginButton()
        XCTAssertEqual(homeScreen.title.label, "Home")
    }
    
    func test_loginCancelPath() throws {
        agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
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
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
        // Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.oAuthErrorButton.label, "Redirect with OAuth error")
        // Redirect with OAuth error
        let errorScreen = loginModal.tapBrowserRedirectWithOAuthErrorButton()
        XCTAssertEqual(errorScreen.title.label, "There was a problem signing you in")
        XCTAssertEqual(errorScreen.body.label, "You can try signing in again.\n\nIf this does not work, you may need to try again later.")
        XCTAssertEqual(errorScreen.closeButton.label, "Close")
    }
    
    func test_invalidStateError() throws {
        agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
        // Login Modal
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.invalidStateButton.label, "Redirect with invalid state")
        // Redirect with invalid state
        let errorScreen = loginModal.tapBrowserInvalidStateErrorButton()
        XCTAssertEqual(errorScreen.title.label, "There was a problem signing you in")
        XCTAssertEqual(errorScreen.body.label, "You can try signing in again.\n\nIf this does not work, you may need to try again later.")
        XCTAssertEqual(errorScreen.closeButton.label, "Close")
    }
    
    func test_fourHundredResponseError() throws {
        agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
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
        XCTAssertEqual(errorScreen.body.label, "You can try signing in again.\n\nIf this does not work, you may need to try again later.")
        XCTAssertEqual(errorScreen.closeButton.label, "Close")
    }
    
    func test_fiveHundredResponseError() throws {
        agreeIfAnalytics()
        // Welcome Screen
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
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
        XCTAssertEqual(errorScreen.body.label, "You can try signing in again.\n\nIf this does not work, you may need to try again later.")
        XCTAssertEqual(errorScreen.closeButton.label, "Close")
    }
}
