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
    }
}
