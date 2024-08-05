import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class GenericErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: GenericErrorViewModel!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = GenericErrorViewModel(errorDescription: "error description",
                                    analyticsService: mockAnalyticsService) {
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
        XCTAssertEqual(sut.errorDescription, "error description")
    }
    
    func test_button_action() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_closeButton",
                              linkDomain: AppEnvironment.oneLoginBaseURL,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["link_domain"],
                       event.parameters["link_domain"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["external"],
                       event.parameters["external"])
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.generic.rawValue,
                                     screen: ErrorAnalyticsScreen.generic,
                                     titleKey: "app_somethingWentWrongErrorTitle",
                                     reason: sut.errorDescription)
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"],
                       screen.parameters["screen_id"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["reason"],
                       screen.parameters["reason"])
    }
}
