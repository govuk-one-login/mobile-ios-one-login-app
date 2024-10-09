import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class SignOutErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignOutErrorViewModel!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignOutErrorViewModel(analyticsService: mockAnalyticsService,
                                    error: MockWalletError.cantDelete)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        
        super.tearDown()
    }
}

extension SignOutErrorViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_signOutErrorTitle")
        XCTAssertEqual(sut.body, "app_signOutErrorBody")
        XCTAssertTrue(sut.error as? MockWalletError == .cantDelete)
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertEqual(sut.rightBarButtonTitle?.stringKey, "app_cancelButton")
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_exitButton")
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.crashesLogged.count, 0)
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.crashesLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        XCTAssertTrue(mockAnalyticsService.crashesLogged.first as? MockWalletError == .cantDelete)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.signOut.rawValue,
                                     screen: ErrorAnalyticsScreen.signOut,
                                     titleKey: "app_signOutErrorTitle",
                                     reason: MockWalletError.cantDelete.localizedDescription)
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
