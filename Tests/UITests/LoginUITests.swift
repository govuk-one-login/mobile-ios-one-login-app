import XCTest

final class LoginUITests: XCTestCase {
    var sut: WelcomeScreen!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        await MainActor.run {
            sut = WelcomeScreen()
            sut.app.launch()
        }
    }
    
    override func tearDown() {
        sut.app.terminate()
        sut = nil
        super.tearDown()
    }
}

extension LoginUITests {
    func test_loginHappyPath() throws {
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertEqual(sut.signInButton.label, "Sign in")
        let loginModal = sut.tapLoginButton()
        _ = loginModal.title.waitForExistence(timeout: .timeout)
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertEqual(loginModal.loginButton.label, "Login")
    }
    
    func test_loginCancelPath() throws {
        let loginModal = sut.tapLoginButton()
        loginModal.tapCancelButton()
        XCTAssertTrue(sut.isVisible)
    }
}
