import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class SignOutSuccessfulViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignOutSuccessfulViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignOutSuccessfulViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        didCallButtonAction = false
        
        super.tearDown()
    }
}

extension SignOutSuccessfulViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.title.stringKey, "app_signedOutTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_signedOutBodyNoWallet")
        XCTAssertEqual(sut.rightBarButtonTitle?.stringKey, nil)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_page_withWallet() {
        sut = SignOutSuccessfulViewModel(analyticsService: mockAnalyticsService,
                                         withWallet: true) {
            self.didCallButtonAction = true
        }
        XCTAssertEqual(sut.title.stringKey, "app_signedOutTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_signedOutBodyWithWallet")
        XCTAssertEqual(sut.rightBarButtonTitle?.stringKey, nil)
        XCTAssertTrue(sut.backButtonIsHidden)
    }

    func test_button() throws {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_continueButton")
        let button = try XCTUnwrap(sut.primaryButtonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsGreen)
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_continueButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear_noWallet() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.signOutSuccessfulScreenNoWallet.rawValue,
                                screen: SettingsAnalyticsScreen.signOutSuccessfulScreenNoWallet,
                                titleKey: "app_signedOutTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.signout)
    }
    
    func test_didAppear_withWallet() {
        sut = SignOutSuccessfulViewModel(analyticsService: mockAnalyticsService,
                                         withWallet: true) {
            self.didCallButtonAction = true
        }
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.signOutSuccessfulScreenWithWallet.rawValue,
                                screen: SettingsAnalyticsScreen.signOutSuccessfulScreenWithWallet,
                                titleKey: "app_signedOutTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.signout)
    }
}
