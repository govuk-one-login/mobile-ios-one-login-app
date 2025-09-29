import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class SignOutSuccessfulViewModelTests: XCTestCase {
    var sut: SignOutSuccessfulViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        sut = SignOutSuccessfulViewModel {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        sut = nil
        
        didCallButtonAction = false
        
        super.tearDown()
    }
}

extension SignOutSuccessfulViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.title.stringKey, "app_signedOutTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_signedOutBody")
    }

    func test_button() throws {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_continueButton")
        XCTAssertFalse(didCallButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
