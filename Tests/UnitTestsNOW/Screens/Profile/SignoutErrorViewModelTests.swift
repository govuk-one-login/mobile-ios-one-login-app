import GDSAnalytics
import GDSCommon
@testable import OneLoginNOW
import XCTest

import Foundation

final class SignoutErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignoutErrorViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignoutErrorViewModel(errorDescription: "Error",
                                    analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
    }
}

extension SignoutErrorViewModelTests {
    func test_pageConfiguration() throws {
        XCTAssertEqual(sut.title.stringKey, "app_signOutErrorTitle")
        XCTAssertEqual(sut.body, "app_signOutErrorBody")
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
        XCTAssertEqual(sut.errorDescription, "Error")
    }
    
    func test_buttonConfiuration() throws {
        XCTAssertTrue(sut.primaryButtonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.primaryButtonViewModel.title, GDSLocalisedString(stringLiteral: "app_exitButton"))
        let button = try XCTUnwrap(sut.primaryButtonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsGreen)
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
