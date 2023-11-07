import XCTest

final class LoginUITests: XCTestCase {
    var sut: WelcomeScreenObject!
    
    override func setUp() async throws {
        continueAfterFailure = false
        
        await MainActor.run {
            sut = WelcomeScreenObject()
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
        XCTAssertTrue(sut.title.exists)
        XCTAssertEqual(sut.title.label, "GOV.UK One Login")
        XCTAssertTrue(sut.body.exists)
        XCTAssertEqual(sut.body.label, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertTrue(sut.signInButton.exists)
        XCTAssertEqual(sut.signInButton.label, "Sign in")
        let loginModal = sut.tapLoginButton()
        XCTAssertTrue(loginModal.title.exists)
        XCTAssertEqual(loginModal.title.label, "Welcome to the Auth Stub")
        XCTAssertTrue(loginModal.loginButton.exists)
        XCTAssertEqual(loginModal.loginButton.label, "Login")
    }
    
    func test_loginCancelPath() throws {
        let loginModal = sut.tapLoginButton()
        XCTAssertTrue(loginModal.cancelButton.exists)
        let welcomeScreen = loginModal.tapCancelButton()
        XCTAssertTrue(welcomeScreen.isVisible)
    }
}
