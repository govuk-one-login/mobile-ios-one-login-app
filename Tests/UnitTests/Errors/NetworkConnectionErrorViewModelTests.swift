import GDSAnalytics
@testable import OneLogin
import XCTest

final class NetworkConnectionErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: NetworkConnectionErrorViewModel!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = NetworkConnectionErrorViewModel(analyticsService: mockAnalyticsService) {
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

extension NetworkConnectionErrorViewModelTests {
    func test_labelContents() throws {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.value, "You appear to be offline")
        XCTAssertEqual(sut.body.value, "GOV.UK One Login is not avaliable offline. \nReconnect to the internet to continue.")
    }
    
    func test_buttonAction() throws {
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
        let screen = ScreenView(screen: ErrorAnalyticsScreen.networkConnection,
                                titleKey: "You appear to be offline")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
    }
}
