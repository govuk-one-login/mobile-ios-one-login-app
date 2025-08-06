import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class UnrecoverableLoginErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: UnrecoverableLoginErrorViewModel!
        
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = UnrecoverableLoginErrorViewModel(analyticsService: mockAnalyticsService,
                                               errorDescription: "error description")
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
                
        super.tearDown()
    }
}

extension UnrecoverableLoginErrorViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_signInErrorTitle")
        XCTAssertEqual(sut.bodyContent.count, 1)
        XCTAssertEqual(sut.buttonViewModels.count, 0)

    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.unrecoverableLoginError.rawValue,
                                     screen: ErrorAnalyticsScreen.unrecoverablLoginError,
                                     titleKey: "app_signInErrorTitle",
                                     reason: "error description")
        XCTAssertEqual(mockAnalyticsService.screenViews as? [ErrorScreenView], [screen])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
