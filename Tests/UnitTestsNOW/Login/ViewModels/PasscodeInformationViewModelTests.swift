import GDSAnalytics
@testable import OneLoginNOW
import XCTest

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
    func test_label_contents() throws {
        XCTAssertEqual(sut.image, "lock")
        XCTAssertEqual(sut.title.stringKey, "app_noPasscodeSetupTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_noPasscodeSetupBody")
    }
    
    func test_button_action() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_continueButton",
                              linkDomain: AppEnvironment.oneLoginBaseURL,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["link_domain"], event.parameters["link_domain"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["external"], event.parameters["external"])
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: InformationAnalyticsScreenID.passcodeInfoScreen.rawValue,
                                screen: InformationAnalyticsScreen.passcode,
                                titleKey: "app_noPasscodeSetupTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
    }
}
