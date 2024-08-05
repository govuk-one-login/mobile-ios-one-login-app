import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class DataDeletedWarningViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: DataDeletedWarningViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = DataDeletedWarningViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
    }
}

extension DataDeletedWarningViewModelTests {
    func test_pageConfiguration() throws {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_somethingWentWrongErrorTitle")
        XCTAssertEqual(sut.body, "app_dataDeletionWarningBody")
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_buttonConfiuration() throws {
        XCTAssertTrue(sut.primaryButtonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.primaryButtonViewModel.title, GDSLocalisedString(stringLiteral: "app_extendedSignInButton"))
        let button = try XCTUnwrap(sut.primaryButtonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsGreen)
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
