import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class TouchIDEnrolmentViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: TouchIDEnrolmentViewModel!
    
    var didCallPrimaryButtonAction = false
    var didCallSecondaryButtonAction = false

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = TouchIDEnrolmentViewModel(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryButtonAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryButtonAction = true
        }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        didCallPrimaryButtonAction = false
        didCallSecondaryButtonAction = false

        super.tearDown()
    }
}

extension TouchIDEnrolmentViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, "touchid")
        XCTAssertEqual(sut.title.stringKey, "app_enableTouchIDTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_enableTouchIDBody")
        XCTAssertEqual(sut.footnote.stringKey, "app_enableTouchIDFootnote")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }

    func test_primaryButton() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_enableTouchIDEnableButton")
        XCTAssertFalse(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_enableTouchIDEnableButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }

    func test_secondaryButton() {
        XCTAssertEqual(sut.secondaryButtonViewModel.title.stringKey, "app_maybeLaterButton")
        XCTAssertFalse(didCallSecondaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.secondaryButtonViewModel.action()
        XCTAssertTrue(didCallSecondaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_maybeLaterButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }

    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.touchIDEnrollment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.touchIDEnrollment,
                                titleKey: "app_enableTouchIDTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
