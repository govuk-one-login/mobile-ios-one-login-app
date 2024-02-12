import GDSAnalytics
@testable import OneLogin
import XCTest

final class GenericErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: GenericErrorViewModel!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = GenericErrorViewModel(analyticsService: mockAnalyticsService) {
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

extension GenericErrorViewModelTests {
    func test_label_contents() throws {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_somethingWentWrongErrorTitle")
        XCTAssertEqual(sut.body.stringKey, "app_somethingWentWrongErrorBody")
    }
    
    func test_button_action() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: sut.primaryButtonViewModel.title.value)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(screen: ErrorAnalyticsScreen.generic,
                                titleKey: "app_somethingWentWrongErrorTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
    }
}
