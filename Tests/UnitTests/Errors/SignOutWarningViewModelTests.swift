import GDSCommon
@testable import OneLogin
import XCTest

final class SignOutWarningViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignOutWarningViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignOutWarningViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
    }
}

extension SignOutWarningViewModelTests {
    func test_pageConfiguration() throws {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_signOutWarningTitle")
        XCTAssertEqual(sut.body, "app_signOutWarningBody")
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_buttonConfiuration() throws {
        XCTAssertTrue(sut.primaryButtonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.primaryButtonViewModel.title, GDSLocalisedString(stringLiteral: "app_signInButton"))
        let button = try XCTUnwrap(sut.primaryButtonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsGreen)
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
