import GDSAnalytics
@testable import OneLogin
import XCTest

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
    }
}

extension UnlockScreenViewModelTests {
    func test_buttonContents() throws {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_unlockButton")
    }

    func test_primaryButton_action() throws {
        XCTAssertFalse(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_unlockButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
    }

    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
    }
}
