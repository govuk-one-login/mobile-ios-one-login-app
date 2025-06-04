import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
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
    func test_page() throws {
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_networkErrorTitle")
        XCTAssertEqual(sut.title.value, "You are not connected to the internet")
        XCTAssertEqual(sut.bodyContent.count, 1)
        let bodyLabel = try XCTUnwrap(sut.bodyContent[0].uiView as? UILabel)
        XCTAssertEqual(bodyLabel.text, "You need to have an internet connection to use GOV.UK One Login.\n\nReconnect to the internet and try again.")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.buttonViewModels[0].title.stringKey, "app_tryAgainButton")
        XCTAssertEqual(sut.buttonViewModels[0].title.value, "Go back and try again")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModels[0].action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_tryAgainButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.networkConnection.rawValue,
                                     screen: ErrorAnalyticsScreen.networkConnection,
                                     titleKey: "app_networkErrorTitle",
                                     reason: "network connection error")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
