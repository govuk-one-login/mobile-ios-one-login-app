import XCTest

final class LoginUITests: XCTestCase {
    var sut: WelcomeScreen!

    override func setUp() async throws {
        continueAfterFailure = false

        await MainActor.run {
            sut = WelcomeScreen()
            sut.app.launch()
        }
    }

    override func tearDown() {
        sut.app.terminate()
        sut = nil
    }
}

extension LoginUITests {
    func test_loginHappyPath() throws {
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.loginButton.label, "Login")
        let userInfoScreen = loginModal.tapBrowserLoginButton()
        XCTAssertEqual(userInfoScreen.title.label, "Logged in")
    }

    func test_loginCancelPath() throws {
        let loginModal = sut.tapLoginButton()
        loginModal.tapCancelButton()
        XCTAssertTrue(sut.isVisible)
    }

    func test_loginGenericError() throws {
        let loginModal = sut.tapLoginButton()
        XCTAssertEqual(loginModal.oAuthErrorButton.label, "Redirect with OAuth error")
        let errorScreen = loginModal.tapBrowserRedirectWithOAuthErrorButton()
        XCTAssertEqual(errorScreen.title.label, "Something went wrong")
        XCTAssertEqual(errorScreen.body.label, "Try again later")
        XCTAssertEqual(errorScreen.closeButton.label, "Close")
    }
}
