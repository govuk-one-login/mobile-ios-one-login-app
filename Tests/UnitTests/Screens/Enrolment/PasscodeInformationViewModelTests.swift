import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class PasscodeInformationViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: PasscodeInformationViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = PasscodeInformationViewModel(analyticsService: mockAnalyticsService) {
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

extension PasscodeInformationViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, "lock")
        XCTAssertEqual(sut.title.stringKey, "app_noPasscodeSetupTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_noPasscodeSetupBody")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_continueButton")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_continueButton",
                              linkDomain: AppEnvironment.oneLoginBaseURL,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: InformationAnalyticsScreenID.passcodeInfoScreen.rawValue,
                                screen: InformationAnalyticsScreen.passcode,
                                titleKey: "app_noPasscodeSetupTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
