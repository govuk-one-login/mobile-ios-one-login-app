import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class UnlockScreenViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: UnlockScreenViewModel!
    
    var didCallPrimaryButtonAction = false

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = UnlockScreenViewModel(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryButtonAction = true
        }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut =  nil
        
        didCallPrimaryButtonAction = false
        
        super.tearDown()
    }
}

extension UnlockScreenViewModelTests {
    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_unlockButton")
        XCTAssertFalse(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_unlockButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }

    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.unlock.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.unlock,
                                titleKey: "one login unlock screen")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
